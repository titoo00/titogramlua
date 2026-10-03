local api = require('spec.test_helper')

describe('handlers', function()
    describe('process_update', function()
        it('returns false for nil update', function()
            assert.is_false(api.process_update(nil))
        end)

        it('calls on_update for every update', function()
            local called = false
            api.on_update = function(_) called = true end
            api.process_update({ message = { chat = { type = 'private' }, text = 'hi' }})
            assert.is_true(called)
            api.on_update = function(_) end
        end)

        it('routes message to on_message', function()
            local msg = nil
            api.on_message = function(m) msg = m end
            local update = { message = { chat = { type = 'private' }, text = 'hello' }}
            api.process_update(update)
            assert.equals('hello', msg.text)
            api.on_message = function(_) end
        end)

        it('routes private message to on_private_message', function()
            local called = false
            api.on_private_message = function(_) called = true end
            api.process_update({ message = { chat = { type = 'private' }}})
            assert.is_true(called)
            api.on_private_message = function(_) end
        end)

        it('routes group message to on_group_message', function()
            local called = false
            api.on_group_message = function(_) called = true end
            api.process_update({ message = { chat = { type = 'group' }}})
            assert.is_true(called)
            api.on_group_message = function(_) end
        end)

        it('routes supergroup message to on_supergroup_message', function()
            local called = false
            api.on_supergroup_message = function(_) called = true end
            api.process_update({ message = { chat = { type = 'supergroup' }}})
            assert.is_true(called)
            api.on_supergroup_message = function(_) end
        end)

        it('routes edited_message', function()
            local called = false
            api.on_edited_message = function(_) called = true end
            api.process_update({ edited_message = { chat = { type = 'private' }}})
            assert.is_true(called)
            api.on_edited_message = function(_) end
        end)

        it('routes callback_query', function()
            local called = false
            api.on_callback_query = function(_) called = true end
            api.process_update({ callback_query = { id = '123' }})
            assert.is_true(called)
            api.on_callback_query = function(_) end
        end)

        it('routes inline_query', function()
            local called = false
            api.on_inline_query = function(_) called = true end
            api.process_update({ inline_query = { id = '123' }})
            assert.is_true(called)
            api.on_inline_query = function(_) end
        end)

        it('routes channel_post', function()
            local called = false
            api.on_channel_post = function(_) called = true end
            api.process_update({ channel_post = { text = 'hi' }})
            assert.is_true(called)
            api.on_channel_post = function(_) end
        end)

        it('routes poll_answer (bug fix from v2)', function()
            local called = false
            api.on_poll_answer = function(_) called = true end
            api.process_update({ poll_answer = { poll_id = '1' }})
            assert.is_true(called)
            api.on_poll_answer = function(_) end
        end)

        it('routes message_reaction (bug fix from v2)', function()
            local called = false
            api.on_message_reaction = function(_) called = true end
            api.process_update({ message_reaction = { chat = {} }})
            assert.is_true(called)
            api.on_message_reaction = function(_) end
        end)

        it('routes business_connection (new in v3)', function()
            local called = false
            api.on_business_connection = function(_) called = true end
            api.process_update({ business_connection = { id = '1' }})
            assert.is_true(called)
            api.on_business_connection = function(_) end
        end)

        it('routes purchased_paid_media (new in v3)', function()
            local called = false
            api.on_purchased_paid_media = function(_) called = true end
            api.process_update({ purchased_paid_media = {} })
            assert.is_true(called)
            api.on_purchased_paid_media = function(_) end
        end)

        it('routes managed_bot update', function()
            local called = false
            api.on_managed_bot = function(_) called = true end
            api.process_update({ managed_bot = { user = {}, bot = {} } })
            assert.is_true(called)
            api.on_managed_bot = function(_) end
        end)

        it('returns false for unknown update type', function()
            assert.is_false(api.process_update({ unknown_type = {} }))
        end)
    end)

    -- regression coverage for issue #46: sync polling crashed when the
    -- underlying http transport raised a lua error (luasocket/luasec
    -- 'wantread' or 'unexpected eof while reading'). _run_sync now wraps
    -- get_updates in pcall, applies exponential backoff, and exits cleanly
    -- on api.stop_sync().
    describe('_run_sync', function()
        local original_get_updates
        local original_on_message
        local sleeps

        before_each(function()
            original_get_updates = api.get_updates
            original_on_message = api.on_message
            sleeps = {}
        end)

        after_each(function()
            api.get_updates = original_get_updates
            api.on_message = original_on_message
            api._sync_running = false
        end)

        local function record_sleeper(seconds)
            table.insert(sleeps, seconds)
        end

        it('exits cleanly when stop_sync is called', function()
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                api.stop_sync()
                return { ok = true, result = {} }, 200
            end
            api._run_sync({ _sleeper = record_sleeper })
            assert.equals(1, calls)
        end)

        it('survives a thrown lua error from get_updates', function()
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls == 1 then
                    error("Copas 'try' error intermediate table: 'wantread'")
                end
                api.stop_sync()
                return { ok = true, result = {} }, 200
            end
            assert.has_no_error(function()
                api._run_sync({ _sleeper = record_sleeper })
            end)
            assert.equals(2, calls)
            assert.equals(1, #sleeps)
            assert.equals(1, sleeps[1])
        end)

        it('survives unexpected eof and resumes processing updates', function()
            local handled = {}
            api.on_message = function(message)
                table.insert(handled, message.text)
            end
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls == 1 then
                    error("Copas 'try' error intermediate table: 'unexpected eof while reading'")
                end
                api.stop_sync()
                return { ok = true, result = {
                    { update_id = 1, message = { chat = { type = 'private' }, text = 'recovered' }},
                }}, 200
            end
            api._run_sync({ _sleeper = record_sleeper })
            assert.equals(1, #handled)
            assert.equals('recovered', handled[1])
        end)

        it('survives get_updates returning false (network/api error)', function()
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls < 3 then
                    return false, 'connection refused'
                end
                api.stop_sync()
                return { ok = true, result = {} }, 200
            end
            assert.has_no_error(function()
                api._run_sync({ _sleeper = record_sleeper })
            end)
            assert.equals(3, calls)
            assert.equals(2, #sleeps)
        end)

        it('applies exponential backoff and caps at 30s', function()
            local calls = 0
            api.get_updates = function()
                calls = calls + 1
                if calls > 8 then
                    api.stop_sync()
                    return { ok = true, result = {} }, 200
                end
                error("Copas 'try' error intermediate table: 'wantread'")
            end
            api._run_sync({ _sleeper = record_sleeper })
            -- 8 errors -> 8 sleeps: 1, 2, 4, 8, 16, 30, 30, 30
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

        it('resets backoff after a successful poll', function()
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
                api.stop_sync()
                return { ok = true, result = {} }, 200
            end
            api._run_sync({ _sleeper = record_sleeper })
            -- expected sleep sequence: 1 (err), 2 (err), <success: reset>, 1 (err)
            assert.equals(3, #sleeps)
            assert.equals(1, sleeps[1])
            assert.equals(2, sleeps[2])
            assert.equals(1, sleeps[3])
        end)

        it('processes updates and advances offset on success', function()
            local handled = {}
            api.on_message = function(message)
                table.insert(handled, message.text)
            end
            local seen_offsets = {}
            local calls = 0
            api.get_updates = function(opts)
                calls = calls + 1
                table.insert(seen_offsets, opts.offset)
                if calls == 1 then
                    return { ok = true, result = {
                        { update_id = 10, message = { chat = { type = 'private' }, text = 'a' }},
                        { update_id = 11, message = { chat = { type = 'private' }, text = 'b' }},
                    }}, 200
                end
                api.stop_sync()
                return { ok = true, result = {} }, 200
            end
            api._run_sync({ _sleeper = record_sleeper })
            assert.same({ 'a', 'b' }, handled)
            assert.equals(0, seen_offsets[1])
            assert.equals(12, seen_offsets[2])
        end)
    end)
end)
