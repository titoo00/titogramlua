local api = require('spec.test_helper')

describe('middleware', function()
    local call_order

    before_each(function()
        api._clear_requests()
        api._middleware = {}
        api._scoped_middleware = {}
        call_order = {}
        -- Reset handler stubs
        api.on_update = function(_) end
        api.on_message = function(_) end
        api.on_private_message = function(_) end
        api.on_callback_query = function(_) end
    end)

    after_each(function()
        api._middleware = {}
        api._scoped_middleware = {}
    end)

    describe('api.use()', function()
        it('registers global middleware', function()
            local fn = function(ctx, next) next() end
            api.use(fn)
            assert.equals(1, #api._middleware)
            assert.equals(fn, api._middleware[1])
        end)

        it('registers multiple middleware in order', function()
            local fn1 = function(ctx, next) next() end
            local fn2 = function(ctx, next) next() end
            api.use(fn1)
            api.use(fn2)
            assert.equals(2, #api._middleware)
            assert.equals(fn1, api._middleware[1])
            assert.equals(fn2, api._middleware[2])
        end)
    end)

    describe('middleware execution', function()
        it('executes middleware in order before handler', function()
            api.use(function(ctx, next)
                table.insert(call_order, 'mw1-before')
                next()
                table.insert(call_order, 'mw1-after')
            end)
            api.use(function(ctx, next)
                table.insert(call_order, 'mw2-before')
                next()
                table.insert(call_order, 'mw2-after')
            end)
            api.on_message = function(msg)
                table.insert(call_order, 'handler')
            end

            api.process_update({
                update_id = 1,
                message = { chat = { id = 123, type = 'private' }, text = 'hello' }
            })

            assert.same({
                'mw1-before', 'mw2-before', 'handler', 'mw2-after', 'mw1-after'
            }, call_order)
        end)

        it('skips handler when middleware does not call next', function()
            local handler_called = false
            api.use(function(ctx, next)
                -- deliberately not calling next()
            end)
            api.on_message = function(msg)
                handler_called = true
            end

            api.process_update({
                update_id = 1,
                message = { chat = { id = 123, type = 'private' }, text = 'hello' }
            })

            assert.is_false(handler_called)
        end)

        it('provides update_type in context', function()
            local captured_type
            api.use(function(ctx, next)
                captured_type = ctx.update_type
                next()
            end)

            api.process_update({
                update_id = 1,
                callback_query = { id = '42', from = { id = 1 } }
            })

            assert.equals('callback_query', captured_type)
        end)

        it('provides update payload in context', function()
            local captured_msg
            api.use(function(ctx, next)
                captured_msg = ctx.message
                next()
            end)

            local msg = { chat = { id = 123, type = 'private' }, text = 'hi' }
            api.process_update({ update_id = 1, message = msg })

            assert.equals(msg, captured_msg)
        end)

        it('dispatches directly when no middleware registered', function()
            local handler_called = false
            api.on_message = function(msg)
                handler_called = true
            end

            api.process_update({
                update_id = 1,
                message = { chat = { id = 123, type = 'private' }, text = 'hello' }
            })

            assert.is_true(handler_called)
        end)

        it('still calls on_update in dispatch', function()
            local on_update_called = false
            api.use(function(ctx, next) next() end)
            api.on_update = function(update)
                on_update_called = true
            end

            api.process_update({
                update_id = 1,
                message = { chat = { id = 123, type = 'private' }, text = 'hi' }
            })

            assert.is_true(on_update_called)
        end)

        it('returns false for nil update', function()
            api.use(function(ctx, next) next() end)
            assert.is_false(api.process_update(nil))
        end)
    end)

    describe('scoped middleware', function()
        it('registers scoped middleware via api.middleware.on_message.use()', function()
            local scoped_called = false
            api.middleware.on_message.use(function(ctx, next)
                scoped_called = true
                next()
            end)

            api.process_update({
                update_id = 1,
                message = { chat = { id = 123, type = 'private' }, text = 'hi' }
            })

            assert.is_true(scoped_called)
        end)

        it('does not run message middleware for callback_query updates', function()
            local scoped_called = false
            api.middleware.on_message.use(function(ctx, next)
                scoped_called = true
                next()
            end)

            api.process_update({
                update_id = 1,
                callback_query = { id = '42', from = { id = 1 } }
            })

            assert.is_false(scoped_called)
        end)

        it('runs global middleware before scoped middleware', function()
            api.use(function(ctx, next)
                table.insert(call_order, 'global')
                next()
            end)
            api.middleware.on_message.use(function(ctx, next)
                table.insert(call_order, 'scoped')
                next()
            end)
            api.on_message = function(_)
                table.insert(call_order, 'handler')
            end

            api.process_update({
                update_id = 1,
                message = { chat = { id = 123, type = 'private' }, text = 'hi' }
            })

            assert.same({ 'global', 'scoped', 'handler' }, call_order)
        end)

        it('scoped middleware can block handler', function()
            local handler_called = false
            api.middleware.on_callback_query.use(function(ctx, next)
                -- block
            end)
            api.on_callback_query = function(_)
                handler_called = true
            end

            api.process_update({
                update_id = 1,
                callback_query = { id = '42', from = { id = 1 } }
            })

            assert.is_false(handler_called)
        end)
    end)

    describe('error handling', function()
        it('propagates errors from middleware', function()
            api.use(function(ctx, next)
                error('middleware error')
            end)

            assert.has_error(function()
                api.process_update({
                    update_id = 1,
                    message = { chat = { id = 123, type = 'private' }, text = 'hi' }
                })
            end, 'middleware error')
        end)
    end)
end)
