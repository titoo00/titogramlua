-- tests for phase-c framework layer: session, context, command router, conversations
local api = require('spec.test_helper')

local function msg_update(text, chat_id, user_id)
    return {
        update_id = math.random(1, 1e9),
        message = {
            chat = { id = chat_id or 5, type = 'private' },
            from = { id = user_id or 9, first_name = 'Tester' },
            text = text
        }
    }
end

describe('phase C framework', function()
    local saved_on_message
    before_each(function()
        api._clear_requests()
        api._commands = {}
        api._hears = {}
        api._waiters = {}
        api._command_not_found = nil
        saved_on_message = api.on_message
        api.on_message = function() end
    end)
    after_each(function()
        api.on_message = saved_on_message
    end)

    describe('session', function()
        it('returns a persistent table per chat/user', function()
            api.session.clear(msg_update('x', 1, 1))
            local s = api.session.get(msg_update('x', 1, 1))
            s.count = 42
            assert.equals(42, api.session.get(msg_update('y', 1, 1)).count)
        end)

        it('keys distinctly by chat and user', function()
            assert.are_not.equal(api.session.key(msg_update('a', 1, 1)), api.session.key(msg_update('a', 1, 2)))
        end)

        it('clear wipes the session', function()
            api.session.get(msg_update('x', 7, 7)).v = 1
            api.session.clear(msg_update('x', 7, 7))
            assert.is_nil(api.session.get(msg_update('x', 7, 7)).v)
        end)

        it('use swaps the backend', function()
            local default = api.session._backend
            local calls = {}
            api.session.use({
                get = function(_, k) calls[#calls + 1] = k; return {} end,
                set = function() end, clear = function() end
            })
            api.session.get(msg_update('x', 3, 4))
            api.session.use(default)
            assert.equals('3:4', calls[1])
        end)
    end)

    describe('build_context', function()
        it('exposes update_type, chat, from and chat_id for a message', function()
            local ctx = api.build_context(msg_update('hi', 11, 22))
            assert.equals('message', ctx.update_type)
            assert.equals(11, ctx.chat_id)
            assert.equals(22, ctx.from.id)
            assert.equals('hi', ctx.message.text)
        end)

        it('derives chat from callback_query.message', function()
            local ctx = api.build_context({
                callback_query = { id = 'cb1', from = { id = 9 }, message = { chat = { id = 77 } }, data = 'x' }
            })
            assert.equals('callback_query', ctx.update_type)
            assert.equals(77, ctx.chat_id)
        end)

        it('ctx.reply sends to the chat', function()
            local ctx = api.build_context(msg_update('hi', 88))
            ctx.reply('hello there')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendMessage'))
            assert.equals(88, req.parameters.chat_id)
            assert.equals('hello there', req.parameters.text)
        end)

        it('ctx.answer answers a callback query', function()
            local ctx = api.build_context({ callback_query = { id = 'cb9', from = { id = 1 }, message = { chat = { id = 1 } } } })
            ctx.answer({ text = 'done' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/answerCallbackQuery'))
            assert.equals('cb9', req.parameters.callback_query_id)
        end)
    end)

    describe('command router', function()
        it('dispatches a registered command with parsed args', function()
            local seen
            api.command('start', function(ctx) seen = ctx end)
            api.process_update(msg_update('/start hello world', 5, 9))
            assert.is_table(seen)
            assert.equals('start', seen.command)
            assert.equals('hello', seen.args[1])
            assert.equals(5, seen.chat_id)
        end)

        it('a guard can block a command', function()
            local ran = false
            api.command('admin', { guard = function() return false end }, function() ran = true end)
            api.process_update(msg_update('/admin', 5, 9))
            assert.is_false(ran)
        end)

        it('on_command_not_found fires for an unknown command', function()
            local missed
            api.command('start', function() end)
            api.on_command_not_found(function(ctx) missed = ctx.command end)
            api.process_update(msg_update('/nope', 5, 9))
            assert.equals('nope', missed)
        end)

        it('hears matches a text pattern', function()
            local hit
            api.hears('^ping$', function(ctx) hit = ctx.match end)
            api.process_update(msg_update('ping', 5, 9))
            assert.equals('ping', hit)
        end)

        it('falls through to on_message when nothing is registered', function()
            local got
            api.on_message = function(m) got = m.text end
            api.process_update(msg_update('plain text', 5, 9))
            assert.equals('plain text', got)
        end)
    end)

    describe('conversations (sync)', function()
        it('runs a conversation and resumes on the next message', function()
            local steps = {}
            api.conversation('signup', function(ctx)
                table.insert(steps, 'ask')
                ctx.reply('name?')
                local m = ctx.wait_for()
                table.insert(steps, 'got:' .. m.message.text)
            end)
            api.enter('signup', msg_update('/signup', 5, 9))
            assert.same({ 'ask' }, steps)
            api.process_update(msg_update('Alice', 5, 9))
            assert.same({ 'ask', 'got:Alice' }, steps)
            assert.is_nil(api._waiters['5:9'])
        end)

        it('supports multiple turns', function()
            local collected = {}
            api.enter(function(ctx)
                local a = ctx.wait_for()
                collected[#collected + 1] = a.message.text
                local b = ctx.wait_for()
                collected[#collected + 1] = b.message.text
            end, msg_update('/start', 5, 9))
            api.process_update(msg_update('one', 5, 9))
            api.process_update(msg_update('two', 5, 9))
            assert.same({ 'one', 'two' }, collected)
        end)
    end)
end)
