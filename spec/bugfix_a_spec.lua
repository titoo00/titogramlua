-- regression tests for the verified phase-a bug fixes
local api = require('spec.test_helper')

describe('phase A bug fixes', function()

    describe('on_guest_message dispatch', function()
        it('routes guest_message updates to api.on_guest_message', function()
            local got
            local orig = api.on_guest_message
            api.on_guest_message = function(gm) got = gm end
            api.process_update({ update_id = 1, guest_message = { inline_message_id = 'x' } })
            api.on_guest_message = orig
            assert.is_table(got)
            assert.equals('x', got.inline_message_id)
        end)
    end)

    describe('fmt.code markdown escaping', function()
        it('escapes backticks inside markdown code', function()
            assert.equals('`a\\`b`', api.fmt.code('a`b', 'MarkdownV2'))
        end)

        it('escapes backslashes inside markdown code', function()
            assert.equals('`x\\\\y`', api.fmt.code('x\\y', 'MarkdownV2'))
        end)

        it('still uses <code> with html escaping in html mode', function()
            assert.equals('<code>&lt;x&gt;</code>', api.fmt.code('<x>', 'HTML'))
        end)
    end)

    describe('request layer (api._real_request)', function()
        local original
        before_each(function()
            original = require('ssl.https').request
        end)
        after_each(function()
            require('ssl.https').request = original
        end)

        it('does not mutate the caller parameters table', function()
            require('ssl.https').request = function() return 1, 200 end
            local params = { a = 1, b = true, c = 'x' }
            api._real_request('https://example.invalid/test', params)
            assert.equals(1, params.a)
            assert.equals(true, params.b)
            assert.equals('x', params.c)
        end)

        it('returns a structured error when the body is not valid JSON', function()
            require('ssl.https').request = function(t)
                t.sink('<html>502 bad gateway</html>')
                return 1, 200
            end
            local ok, err = api._real_request('https://example.invalid/test', {})
            assert.is_false(ok)
            assert.is_table(err)
            assert.equals('failed to decode API response', err.description)
            assert.truthy(tostring(err.body):find('502'))
        end)
    end)

    describe('sync polling loop resilience', function()
        local original_get_updates, original_on_message
        before_each(function()
            original_get_updates = api.get_updates
            original_on_message = api.on_message
        end)
        after_each(function()
            api.get_updates = original_get_updates
            api.on_message = original_on_message
            api._sync_running = false
        end)

        it('survives a throwing handler and continues to the next update', function()
            local handled = {}
            api.on_message = function(m)
                table.insert(handled, m.text)
                if m.text == 'boom' then error('handler blew up') end
            end
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls == 1 then
                    return { ok = true, result = {
                        { update_id = 1, message = { chat = { type = 'private' }, text = 'boom' } },
                        { update_id = 2, message = { chat = { type = 'private' }, text = 'after' } },
                    } }, 200
                end
                api.stop_sync()
                return { ok = true, result = {} }, 200
            end
            assert.has_no_error(function()
                api._run_sync({ _sleeper = function() end })
            end)
            assert.same({ 'boom', 'after' }, handled)
        end)

        it('processes updates in order and advances offset past the highest update_id', function()
            local order, offsets = {}, {}
            api.on_message = function(m) table.insert(order, m.text) end
            local calls = 0
            api.get_updates = function(opts)
                calls = calls + 1
                table.insert(offsets, opts.offset)
                if calls == 1 then
                    return { ok = true, result = {
                        { update_id = 10, message = { chat = { type = 'private' }, text = 'a' } },
                        { update_id = 11, message = { chat = { type = 'private' }, text = 'b' } },
                        { update_id = 12, message = { chat = { type = 'private' }, text = 'c' } },
                    } }, 200
                end
                api.stop_sync()
                return { ok = true, result = {} }, 200
            end
            api._run_sync({ _sleeper = function() end })
            assert.same({ 'a', 'b', 'c' }, order)
            assert.equals(13, offsets[2])
        end)
    end)
end)
