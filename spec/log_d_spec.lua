-- tests for phase-d structured logging and metrics
local api = require('spec.test_helper')

describe('phase D logging + metrics', function()
    describe('api.log', function()
        local orig_sink, orig_level, orig_debug
        before_each(function()
            orig_sink, orig_level, orig_debug = api.log.sink, api.log.level, api.debug
        end)
        after_each(function()
            api.log.sink, api.log.level, api.debug = orig_sink, orig_level, orig_debug
        end)

        it('routes messages through a custom sink', function()
            local seen = {}
            api.log.sink = function(level, msg) seen[#seen + 1] = { level, msg } end
            api.log.level = 'info'
            api.log.warn('hello', 'world')
            assert.equals('warn', seen[1][1])
            assert.equals('hello world', seen[1][2])
        end)

        it('filters messages below the configured level', function()
            local n = 0
            api.log.sink = function() n = n + 1 end
            api.log.level = 'warn'
            api.debug = false
            api.log.info('x')
            api.log.debug('y')
            assert.equals(0, n)
            api.log.warn('z')
            assert.equals(1, n)
        end)

        it('emits debug logs when api.debug is set even at a higher level', function()
            local n = 0
            api.log.sink = function() n = n + 1 end
            api.log.level = 'info'
            api.debug = true
            api.log.debug('d')
            assert.equals(1, n)
        end)
    end)

    describe('api.metrics', function()
        before_each(function() api.metrics.reset() end)

        it('increments and reads counters', function()
            api.metrics.incr('updates')
            api.metrics.incr('updates', 4)
            assert.equals(5, api.metrics.get('updates'))
        end)

        it('all() returns a snapshot copy', function()
            api.metrics.incr('a')
            local snap = api.metrics.all()
            api.metrics.incr('a')
            assert.equals(1, snap.a)
            assert.equals(2, api.metrics.get('a'))
        end)

        it('reset clears counters', function()
            api.metrics.incr('a')
            api.metrics.reset()
            assert.equals(0, api.metrics.get('a'))
        end)
    end)
end)
