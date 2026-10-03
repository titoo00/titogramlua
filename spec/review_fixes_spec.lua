-- tests for the two bugs found in adversarial review, plus small coverage gaps
local api = require('spec.test_helper')

local function msg_update(text, chat_id, user_id)
    return {
        update_id = 1,
        message = {
            chat = { id = chat_id or 5, type = 'private' },
            from = { id = user_id or 9, first_name = 'Tester' },
            text = text
        }
    }
end

describe('review fixes', function()

    -- bug #2: async _http_request must inject every file part, not just one.
    it('async _http_request includes all file parts (not just the first)', function()
        local copas_http = require('copas.http')
        local orig = copas_http.request
        local captured = ''
        copas_http.request = function(t)
            local parts = {}
            local chunk = t.source()
            while chunk do
                parts[#parts + 1] = chunk
                chunk = t.source()
            end
            captured = table.concat(parts)
            t.sink('{"ok":true,"result":true}')
            return 1, 200
        end
        -- file values are non-existent paths, so they pass through as plain
        -- form fields (io.open fails) but still appear as named parts.
        api.async._http_request('https://example.invalid/sendAudio',
            { chat_id = 1 }, { audio = 'file_id_audio', thumbnail = 'file_id_thumb' })
        copas_http.request = orig
        assert.truthy(captured:find('name="audio"'))
        assert.truthy(captured:find('name="thumbnail"'))
    end)

    -- bug #1: async conversation wait_for must block until the next message
    -- (copas.queue defaults to a 10s pop timeout without math.huge).
    it('async conversation path resumes via the mailbox', function()
        local copas = require('copas')
        api.async._running = true
        local got
        copas.addthread(function()
            api.enter(function(ctx) got = ctx.wait_for() end, msg_update('/x', 5, 9))
        end)
        copas.addthread(function()
            copas.sleep(0.01)
            api._conversation_resume(api.build_context(msg_update('reply', 5, 9)))
        end)
        copas.loop()
        api.async._running = false
        assert.is_table(got)
        assert.equals('reply', got.message.text)
    end)

    -- coverage gap: the default in-memory session backend's set path
    it('session.set replaces the stored value', function()
        api.session.set(msg_update('x', 50, 60), { stage = 'done' })
        assert.equals('done', api.session.get(msg_update('y', 50, 60)).stage)
        api.session.clear(msg_update('x', 50, 60))
    end)

    -- coverage gap: log.error path
    it('log.error emits at error level', function()
        local orig_sink = api.log.sink
        local seen
        api.log.sink = function(level, msg) seen = { level, msg } end
        api.log.error('boom')
        api.log.sink = orig_sink
        assert.equals('error', seen[1])
        assert.equals('boom', seen[2])
    end)
end)
