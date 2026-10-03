-- end-to-end integration against a mock transport that returns response shapes
-- matching the telegram bot api documentation. exercises the real request
-- layer (multipart encode, json parse, retry), real dispatch, and the
-- framework — not the unit-level api.request stub.
local api = require('spec.test_helper')

describe('integration against a mock telegram API', function()
    local https = require('ssl.https')
    local orig_https, orig_request
    local last_request, responses

    -- the real request path (test_helper replaces api.request with a stub).
    local function real_request(endpoint, parameters, file)
        return api._with_retry(function()
            return api._http_request(endpoint, parameters, file)
        end)
    end

    before_each(function()
        orig_https, orig_request = https.request, api.request
        api.request = real_request
        last_request, responses = nil, {}
        https.request = function(t)
            local parts = {}
            local chunk = t.source()
            while chunk do
                parts[#parts + 1] = chunk
                chunk = t.source()
            end
            last_request = { url = t.url, body = table.concat(parts) }
            local method = t.url:match('/([%a]+)$')
            local resp = responses[method]
            if type(resp) == 'function' then resp = resp() end
            t.sink(resp or '{"ok":true,"result":true}')
            return 1, 200
        end
    end)

    after_each(function()
        https.request = orig_https
        api.request = orig_request
        api._sync_running = false
    end)

    it('get_me parses a documented User response', function()
        responses.getMe = '{"ok":true,"result":{"id":42,"is_bot":true,"first_name":"MockBot","username":"mock_bot"}}'
        local res = api.get_me()
        assert.is_true(res.ok)
        assert.equals(42, res.result.id)
        assert.equals('MockBot', res.result.first_name)
    end)

    it('send_message produces a well-formed multipart request and parses the Message', function()
        responses.sendMessage = '{"ok":true,"result":{"message_id":100,"chat":{"id":123,"type":"private"},"text":"hi"}}'
        local res = api.send_message(123, 'hi')
        assert.is_true(res.ok)
        assert.equals(100, res.result.message_id)
        assert.truthy(last_request.url:find('/sendMessage'))
        assert.truthy(last_request.body:find('name="chat_id"'))
        assert.truthy(last_request.body:find('123'))
        assert.truthy(last_request.body:find('name="text"'))
    end)

    it('a polling round routes a /start command and the reply is actually sent', function()
        responses.getUpdates = function()
            api.stop_sync()
            return '{"ok":true,"result":[{"update_id":1,"message":{"message_id":5,' ..
                '"chat":{"id":777,"type":"private"},"from":{"id":9},"text":"/start"}}]}'
        end
        responses.sendMessage = '{"ok":true,"result":{"message_id":6}}'
        local saved = api._commands
        api._commands = {}
        api.command('start', function(ctx) ctx.reply('welcome') end)
        api._run_sync({ _sleeper = function() end })
        api._commands = saved
        assert.truthy(last_request.url:find('/sendMessage'))
        assert.truthy(last_request.body:find('777'))
        assert.truthy(last_request.body:find('welcome'))
    end)

    it('honours a documented 429 error then succeeds', function()
        local n = 0
        responses.sendMessage = function()
            n = n + 1
            if n == 1 then
                return '{"ok":false,"error_code":429,"parameters":{"retry_after":0}}'
            end
            return '{"ok":true,"result":{"message_id":1}}'
        end
        local res = api.send_message(1, 'x')
        assert.is_true(res.ok)
        assert.equals(2, n)
    end)

    it('does not retry a documented 400 error', function()
        local n = 0
        responses.sendMessage = function()
            n = n + 1
            return '{"ok":false,"error_code":400,"description":"Bad Request: chat not found"}'
        end
        local res, err = api.send_message(1, 'x')
        assert.is_false(res)
        assert.equals(400, err.error_code)
        assert.equals(1, n)
    end)

    it('webhook.process dispatches a documented update body', function()
        local got
        local saved = api.on_message
        api.on_message = function(m) got = m.text end
        api.webhook.process('{"update_id":9,"message":{"message_id":1,' ..
            '"chat":{"id":1,"type":"private"},"text":"hello"}}')
        api.on_message = saved
        assert.equals('hello', got)
    end)
end)
