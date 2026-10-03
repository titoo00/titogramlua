local api = require('spec.test_helper')
local copas = require('copas')

describe('async', function()
    before_each(function()
        api._clear_requests()
    end)

    describe('module', function()
        it('async table exists on api', function()
            assert.is_table(api.async)
        end)

        it('has run function', function()
            assert.is_function(api.async.run)
        end)

        it('has all function', function()
            assert.is_function(api.async.all)
        end)

        it('has spawn function', function()
            assert.is_function(api.async.spawn)
        end)

        it('has sleep function', function()
            assert.is_function(api.async.sleep)
        end)

        it('has stop function', function()
            assert.is_function(api.async.stop)
        end)

        it('has is_running function', function()
            assert.is_function(api.async.is_running)
        end)

        it('is_running returns false when not running', function()
            assert.is_false(api.async.is_running())
        end)
    end)

    describe('request', function()
        it('is a function', function()
            assert.is_function(api.async.request)
        end)

        it('requires an endpoint', function()
            assert.has_error(function()
                api.async.request(nil, {})
            end)
        end)
    end)

    describe('all', function()
        it('returns empty table for empty input', function()
            local results = api.async.all({})
            assert.is_table(results)
            assert.equals(0, #results)
        end)

        it('runs single function', function()
            local results = api.async.all({
                function() return 42 end
            })
            assert.equals(1, #results)
            assert.equals(42, results[1][1])
        end)

        it('runs multiple functions concurrently', function()
            local order = {}
            local results = api.async.all({
                function()
                    table.insert(order, 'a_start')
                    table.insert(order, 'a_end')
                    return 'a'
                end,
                function()
                    table.insert(order, 'b_start')
                    table.insert(order, 'b_end')
                    return 'b'
                end,
                function()
                    table.insert(order, 'c_start')
                    table.insert(order, 'c_end')
                    return 'c'
                end
            })
            assert.equals(3, #results)
            assert.equals('a', results[1][1])
            assert.equals('b', results[2][1])
            assert.equals('c', results[3][1])
        end)

        it('preserves result order', function()
            local results = api.async.all({
                function() return 1, 'one' end,
                function() return 2, 'two' end,
                function() return 3, 'three' end,
            })
            assert.equals(1, results[1][1])
            assert.equals('one', results[1][2])
            assert.equals(2, results[2][1])
            assert.equals('two', results[2][2])
            assert.equals(3, results[3][1])
            assert.equals('three', results[3][2])
        end)

        it('handles errors gracefully', function()
            local results = api.async.all({
                function() return 'ok' end,
                function() error('boom') end,
                function() return 'also ok' end,
            })
            assert.equals(3, #results)
            assert.equals('ok', results[1][1])
            assert.is_false(results[2][1])
            assert.truthy(tostring(results[2][2]):find('boom'))
            assert.equals('also ok', results[3][1])
        end)

        it('handles nil returns', function()
            local results = api.async.all({
                function() return nil end,
            })
            assert.equals(1, #results)
        end)

        it('handles functions that return false', function()
            local results = api.async.all({
                function() return false, 'error msg' end,
            })
            assert.equals(1, #results)
            assert.is_false(results[1][1])
            assert.equals('error msg', results[1][2])
        end)

        it('handles many concurrent tasks', function()
            local fns = {}
            for i = 1, 50 do
                fns[i] = function() return i end
            end
            local results = api.async.all(fns)
            assert.equals(50, #results)
            for i = 1, 50 do
                assert.equals(i, results[i][1])
            end
        end)
    end)

    describe('spawn', function()
        it('executes the function', function()
            local executed = false
            copas.addthread(function()
                api.async.spawn(function()
                    executed = true
                end)
            end)
            copas.loop()
            assert.is_true(executed)
        end)

        it('can spawn multiple tasks', function()
            local results = {}
            copas.addthread(function()
                api.async.spawn(function()
                    table.insert(results, 'a')
                end)
                api.async.spawn(function()
                    table.insert(results, 'b')
                end)
            end)
            copas.loop()
            assert.equals(2, #results)
        end)
    end)

    describe('sleep', function()
        it('does not error inside copas context', function()
            local completed = false
            copas.addthread(function()
                api.async.sleep(0.01)
                completed = true
            end)
            copas.loop()
            assert.is_true(completed)
        end)

        it('allows other coroutines to run during sleep', function()
            local order = {}
            copas.addthread(function()
                table.insert(order, 'a_start')
                api.async.sleep(0.05)
                table.insert(order, 'a_end')
            end)
            copas.addthread(function()
                table.insert(order, 'b_start')
                api.async.sleep(0.01)
                table.insert(order, 'b_end')
            end)
            copas.loop()
            -- b should finish before a since it sleeps less
            assert.equals('a_start', order[1])
            assert.equals('b_start', order[2])
            assert.equals('b_end', order[3])
            assert.equals('a_end', order[4])
        end)
    end)

    describe('run and stop', function()
        it('stop sets running to false', function()
            api.async._running = true
            api.async.stop()
            assert.is_false(api.async._running)
        end)

        it('run sets running flag', function()
            -- Mock async.request since run() swaps api.request with it
            local call_count = 0
            local original_async_request = api.async.request
            api.async.request = function(endpoint, parameters, file)
                call_count = call_count + 1
                if endpoint:find('/getUpdates') then
                    if call_count > 1 then
                        api.async.stop()
                    end
                    return { ok = true, result = {} }, 200
                end
                return { ok = true, result = true }, 200
            end

            api.async.run({ timeout = 0 })

            assert.truthy(call_count >= 1)
            -- Restore
            api.async.request = original_async_request
        end)

        it('dispatches updates to handlers', function()
            local handled_messages = {}
            local original_on_message = api.on_message
            api.on_message = function(message)
                table.insert(handled_messages, message.text)
            end

            local update_batch = 0
            local original_async_request = api.async.request
            api.async.request = function(endpoint, parameters, file)
                if endpoint:find('/getUpdates') then
                    update_batch = update_batch + 1
                    if update_batch == 1 then
                        return { ok = true, result = {
                            { update_id = 1, message = { chat = { type = 'private' }, text = 'hello' }},
                            { update_id = 2, message = { chat = { type = 'private' }, text = 'world' }},
                        }}, 200
                    else
                        api.async.stop()
                        return { ok = true, result = {} }, 200
                    end
                end
                return { ok = true, result = true }, 200
            end

            api.async.run({ timeout = 0 })

            assert.equals(2, #handled_messages)
            assert.truthy(handled_messages[1] == 'hello' or handled_messages[2] == 'hello')
            assert.truthy(handled_messages[1] == 'world' or handled_messages[2] == 'world')

            -- Restore
            api.on_message = original_on_message
            api.async.request = original_async_request
        end)

        it('handles errors in update handlers without crashing', function()
            local error_handler_called = false
            local original_on_message = api.on_message
            api.on_message = function(message)
                if message.text == 'crash' then
                    error('handler crashed!')
                end
                error_handler_called = true
            end

            local update_batch = 0
            local original_async_request = api.async.request
            api.async.request = function(endpoint, parameters, file)
                if endpoint:find('/getUpdates') then
                    update_batch = update_batch + 1
                    if update_batch == 1 then
                        return { ok = true, result = {
                            { update_id = 1, message = { chat = { type = 'private' }, text = 'crash' }},
                            { update_id = 2, message = { chat = { type = 'private' }, text = 'ok' }},
                        }}, 200
                    else
                        api.async.stop()
                        return { ok = true, result = {} }, 200
                    end
                end
                return { ok = true, result = true }, 200
            end

            -- Should not crash even with erroring handler
            assert.has_no_error(function()
                api.async.run({ timeout = 0 })
            end)

            assert.is_true(error_handler_called)

            api.on_message = original_on_message
            api.async.request = original_async_request
        end)
    end)

    -- regression coverage for issue #46. copas can raise a lua error when
    -- the long-poll connection hits 'wantread' or 'unexpected eof while
    -- reading' (the telegram server closing the keep-alive at the exact
    -- timeout boundary). pre-fix this killed the async polling thread.
    describe('error recovery (issue #46)', function()
        local original_get_updates
        local original_copas_sleep
        local sleeps

        before_each(function()
            original_get_updates = api.get_updates
            original_copas_sleep = copas.sleep
            sleeps = {}
            -- replace copas.sleep so backoff tests don't wait real seconds
            copas.sleep = function(s) table.insert(sleeps, s) end
        end)

        after_each(function()
            api.get_updates = original_get_updates
            copas.sleep = original_copas_sleep
        end)

        it('async.request returns (false, err) when copas raises', function()
            local original_request = api.async.request
            -- inject a copas-shaped failure via the lower-level path. the
            -- test asserts pcall-wrapping inside async.request itself by
            -- using monkey-patched copas.http via package.loaded swap.
            local copas_http = require('copas.http')
            local original_http_request = copas_http.request
            copas_http.request = function()
                error("Copas 'try' error intermediate table: 'wantread'")
            end
            local ok, success, err = pcall(api.async.request, 'https://example.invalid/getUpdates', {})
            assert.is_true(ok)
            assert.is_false(success)
            assert.truthy(tostring(err):find('wantread'))
            copas_http.request = original_http_request
            api.async.request = original_request
        end)

        it('async.run survives a thrown lua error from get_updates', function()
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls == 1 then
                    error("Copas 'try' error intermediate table: 'wantread'")
                end
                api.async.stop()
                return { ok = true, result = {} }, 200
            end
            assert.has_no_error(function()
                api.async.run({ timeout = 0 })
            end)
            assert.equals(2, calls)
            assert.equals(1, #sleeps)
            assert.equals(1, sleeps[1])
        end)

        it('async.run survives unexpected eof and resumes update handling', function()
            local handled = {}
            local original_on_message = api.on_message
            api.on_message = function(message) table.insert(handled, message.text) end
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls == 1 then
                    error("Copas 'try' error intermediate table: 'unexpected eof while reading'")
                end
                api.async.stop()
                return { ok = true, result = {
                    { update_id = 5, message = { chat = { type = 'private' }, text = 'after eof' }},
                }}, 200
            end
            api.async.run({ timeout = 0 })
            assert.equals(1, #handled)
            assert.equals('after eof', handled[1])
            api.on_message = original_on_message
        end)

        it('async.run survives get_updates returning false', function()
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls < 3 then
                    return false, 'connection refused'
                end
                api.async.stop()
                return { ok = true, result = {} }, 200
            end
            assert.has_no_error(function()
                api.async.run({ timeout = 0 })
            end)
            assert.equals(3, calls)
            assert.equals(2, #sleeps)
        end)

        it('async.run applies exponential backoff capped at 30s', function()
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls > 8 then
                    api.async.stop()
                    return { ok = true, result = {} }, 200
                end
                error("Copas 'try' error intermediate table: 'wantread'")
            end
            api.async.run({ timeout = 0 })
            assert.equals(8, #sleeps)
            assert.equals(1, sleeps[1])
            assert.equals(2, sleeps[2])
            assert.equals(4, sleeps[3])
            assert.equals(8, sleeps[4])
            assert.equals(16, sleeps[5])
            assert.equals(30, sleeps[6])
            assert.equals(30, sleeps[7])
            assert.equals(30, sleeps[8])
        end)

        it('async.run resets backoff after a successful poll', function()
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls == 1 or calls == 2 then
                    error("Copas 'try' error intermediate table: 'wantread'")
                end
                if calls == 3 then
                    return { ok = true, result = {} }, 200
                end
                if calls == 4 then
                    error("Copas 'try' error intermediate table: 'wantread'")
                end
                api.async.stop()
                return { ok = true, result = {} }, 200
            end
            api.async.run({ timeout = 0 })
            assert.equals(3, #sleeps)
            assert.equals(1, sleeps[1])
            assert.equals(2, sleeps[2])
            assert.equals(1, sleeps[3])
        end)
    end)

    describe('concurrent API calls within handler', function()
        it('all works inside a copas context', function()
            local results
            copas.addthread(function()
                results = api.async.all({
                    function() return 'msg1' end,
                    function() return 'msg2' end,
                })
            end)
            copas.loop()
            assert.equals(2, #results)
            assert.equals('msg1', results[1][1])
            assert.equals('msg2', results[2][1])
        end)

        it('spawn works inside all context', function()
            local spawned = false
            copas.addthread(function()
                api.async.all({
                    function()
                        api.async.spawn(function()
                            spawned = true
                        end)
                        return 'done'
                    end,
                })
            end)
            copas.loop()
            assert.is_true(spawned)
        end)
    end)
end)
