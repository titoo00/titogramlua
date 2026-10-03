--- structured logging and lightweight metrics.
-- api.log.{debug,info,warn,error} emit through a configurable sink with level
-- filtering; api.metrics holds simple named counters. both are opt-in to
-- configure and have sensible defaults (level 'info', sink = print).
-- @module telegram-bot-lua.log
return function(api)
    api.log = {}

    local levels = { debug = 1, info = 2, warn = 3, error = 4 }

    --- minimum level to emit; one of 'debug', 'info', 'warn', 'error'.
    api.log.level = 'info'

    --- the sink receives (level, message); replace to route logs elsewhere.
    function api.log.sink(level, message)
        print('[' .. level .. '] ' .. message)
    end

    -- debug is also emitted when api.debug is on, for backward compatibility.
    local function should_emit(level)
        if level == 'debug' and api.debug then
            return true
        end
        return levels[level] >= (levels[api.log.level] or levels.info)
    end

    local function emit(level, ...)
        if not should_emit(level) then
            return
        end
        local n = select('#', ...)
        local parts = {}
        for i = 1, n do
            parts[i] = tostring(select(i, ...))
        end
        api.log.sink(level, table.concat(parts, ' '))
    end

    function api.log.debug(...) emit('debug', ...) end
    function api.log.info(...) emit('info', ...) end
    function api.log.warn(...) emit('warn', ...) end
    function api.log.error(...) emit('error', ...) end

    -- metrics: simple named counters (updates processed, requests, retries, ...).
    api.metrics = {}
    api.metrics._counters = {}

    --- increment a named counter by `by` (default 1).
    function api.metrics.incr(name, by)
        api.metrics._counters[name] = (api.metrics._counters[name] or 0) + (by or 1)
    end

    --- read a single counter (0 if unset).
    function api.metrics.get(name)
        return api.metrics._counters[name] or 0
    end

    --- a shallow copy of all counters.
    function api.metrics.all()
        local out = {}
        for k, v in pairs(api.metrics._counters) do
            out[k] = v
        end
        return out
    end

    --- reset all counters to zero.
    function api.metrics.reset()
        api.metrics._counters = {}
    end
end
