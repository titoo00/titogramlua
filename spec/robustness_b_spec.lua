-- tests for phase-b production robustness: retry policy, 409 detection, webhook
local api = require('spec.test_helper')

describe('phase B robustness', function()

    describe('retry policy (api._with_retry)', function()
        it('retries on 429 honouring retry_after, then succeeds', function()
            local attempts, slept = 0, {}
            local function thunk()
                attempts = attempts + 1
                if attempts < 3 then
                    return false, { error_code = 429, parameters = { retry_after = 2 } }
                end
                return { ok = true, result = true }, 200
            end
            local res = api._with_retry(thunk, function(s) table.insert(slept, s) end)
            assert.is_table(res)
            assert.equals(3, attempts)
            assert.same({ 2, 2 }, slept)
        end)

        it('does not retry a normal 4xx api error', function()
            local attempts = 0
            local function thunk()
                attempts = attempts + 1
                return false, { error_code = 400, description = 'bad request' }
            end
            local ok = api._with_retry(thunk, function() end)
            assert.is_false(ok)
            assert.equals(1, attempts)
        end)

        it('retries transient connection errors with exponential backoff', function()
            local attempts, slept = 0, {}
            local function thunk()
                attempts = attempts + 1
                if attempts < 3 then return false, 'connection refused' end
                return { ok = true }, 200
            end
            local res = api._with_retry(thunk, function(s) table.insert(slept, s) end)
            assert.is_table(res)
            assert.equals(3, attempts)
            assert.same({ 1, 2 }, slept)
        end)

        it('gives up after max_attempts and returns the last error', function()
            local attempts = 0
            local function thunk()
                attempts = attempts + 1
                return false, 'still down'
            end
            local ok, err = api._with_retry(thunk, function() end)
            assert.is_false(ok)
            assert.equals('still down', err)
            assert.equals(3, attempts)
        end)

        it('honours api.retry.enabled = false (single attempt, no sleep)', function()
            local saved = api.retry.enabled
            api.retry.enabled = false
            local attempts, slept = 0, 0
            api._with_retry(function()
                attempts = attempts + 1
                return false, 'x'
            end, function() slept = slept + 1 end)
            api.retry.enabled = saved
            assert.equals(1, attempts)
            assert.equals(0, slept)
        end)
    end)

    describe('409 conflict detection (sync loop)', function()
        local orig_gu, orig_print
        before_each(function()
            orig_gu = api.get_updates
            orig_print = _G.print
        end)
        after_each(function()
            api.get_updates = orig_gu
            _G.print = orig_print
            api._sync_running = false
        end)

        it('surfaces a 409 conflict loudly', function()
            local logged = {}
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls == 1 then
                    return false, { error_code = 409, description = 'Conflict' }
                end
                api.stop_sync()
                return { ok = true, result = {} }, 200
            end
            _G.print = function(...) table.insert(logged, tostring((...))) end
            api._run_sync({ _sleeper = function() end })
            _G.print = orig_print
            local found = false
            for _, m in ipairs(logged) do
                if m:find('409') then found = true end
            end
            assert.is_true(found)
        end)
    end)

    describe('webhook', function()
        local orig_on_message
        before_each(function() orig_on_message = api.on_message end)
        after_each(function() api.on_message = orig_on_message end)

        local valid_body = '{"update_id":1,"message":{"chat":{"type":"private"},"text":"hi"}}'

        describe('verify_secret', function()
            it('accepts when no secret is configured', function()
                assert.is_true(api.webhook.verify_secret(nil, nil))
                assert.is_true(api.webhook.verify_secret('anything', ''))
            end)
            it('matches a correct secret', function()
                assert.is_true(api.webhook.verify_secret('s3cret', 's3cret'))
            end)
            it('rejects a wrong or missing secret', function()
                assert.is_false(api.webhook.verify_secret('nope', 's3cret'))
                assert.is_false(api.webhook.verify_secret(nil, 's3cret'))
            end)
        end)

        describe('process', function()
            it('dispatches a valid JSON body', function()
                local got
                api.on_message = function(m) got = m.text end
                api.webhook.process(valid_body)
                assert.equals('hi', got)
            end)
            it('accepts an already-decoded table', function()
                local got
                api.on_message = function(m) got = m.text end
                api.webhook.process({ update_id = 1, message = { chat = { type = 'private' }, text = 'yo' } })
                assert.equals('yo', got)
            end)
            it('rejects a bad secret', function()
                local ok, reason = api.webhook.process('{}', { secret_token = 'x', received_secret = 'y' })
                assert.is_false(ok)
                assert.equals('invalid secret token', reason)
            end)
            it('rejects an invalid payload', function()
                assert.is_false(api.webhook.process('not json at all'))
            end)
        end)

        describe('_dispatch', function()
            local headers = { ['x-telegram-bot-api-secret-token'] = 's' }
            it('returns 200 for a valid POST with matching secret and path', function()
                local status = api.webhook._dispatch('POST', '/hook', headers, valid_body, { secret_token = 's', path = '/hook' })
                assert.equals(200, status)
            end)
            it('405 for a non-POST method', function()
                assert.equals(405, api.webhook._dispatch('GET', '/hook', headers, valid_body, {}))
            end)
            it('404 for a path mismatch', function()
                assert.equals(404, api.webhook._dispatch('POST', '/other', headers, valid_body, { path = '/hook' }))
            end)
            it('401 for a wrong secret', function()
                local status = api.webhook._dispatch('POST', '/hook',
                    { ['x-telegram-bot-api-secret-token'] = 'WRONG' }, valid_body, { secret_token = 's' })
                assert.equals(401, status)
            end)
            it('400 for an invalid body', function()
                assert.equals(400, api.webhook._dispatch('POST', '/hook', headers, 'garbage', { secret_token = 's' }))
            end)
        end)
    end)
end)
