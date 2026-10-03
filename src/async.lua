--- async polling and concurrency via copas.
-- @module telegram-bot-lua.async
--[[
    Async module for telegram-bot-lua.
    Provides coroutine-based concurrency via copas for non-blocking
    API requests, concurrent update processing, and parallel operations.

    Usage:
        -- Process updates concurrently (each handler in its own coroutine)
        api.async.run({ timeout = 60 })

        -- Inside a handler, run multiple API calls in parallel
        local results = api.async.all({
            function() return api.send_message(chat1, 'msg1') end,
            function() return api.send_message(chat2, 'msg2') end,
        })

        -- Spawn a background task
        api.async.spawn(function()
            api.send_typing(chat_id)
            copas.sleep(2)
            api.send_message(chat_id, 'Done thinking!')
        end)

        -- Sleep without blocking other coroutines
        api.async.sleep(1.5)
]]

return function(api)
    local copas = require('copas')
    local copas_http = require('copas.http')
    local ltn12 = require('ltn12')
    local multipart = require('multipart-post')
    local json = require('dkjson')

    api.async = {}
    api.async._running = false

    --- non-blocking HTTP request using copas.
    -- has the same signature as api.request but uses copas.http.
    -- @param endpoint string the full API endpoint URL
    -- @param parameters table optional request parameters
    -- @param file table optional file upload map
    -- @return table decoded JSON response, or false on error
    function api.async._http_request(endpoint, parameters, file)
        assert(endpoint, 'You must specify an endpoint to make this request to!')
        parameters = parameters or {}
        -- shallow copy so the caller's table is never mutated; stringify
        -- scalars for multipart, leave tables (file parts) untouched.
        local params = {}
        for k, v in pairs(parameters) do
            params[k] = type(v) == 'table' and v or tostring(v)
        end
        parameters = params
        if api.debug then
            local safe = {}
            for k, v in pairs(parameters) do safe[k] = v end
            local output = json.encode(safe, { ['indent'] = true })
            print(output)
        end
        -- iterate every file part (mirrors the sync path); next(file) alone
        -- would only handle the first key and silently drop e.g. a thumbnail.
        if file then
            for file_type, file_name in pairs(file) do
                if type(file_name) == 'string' then
                    local file_res = io.open(file_name, 'rb')
                    if file_res then
                        parameters[file_type] = {
                            filename = file_name,
                            data = file_res:read('*a')
                        }
                        file_res:close()
                    else
                        parameters[file_type] = file_name
                    end
                else
                    parameters[file_type] = file_name
                end
            end
        end
        parameters = next(parameters) == nil and {''} or parameters
        local response = {}
        local body, boundary = multipart.encode(parameters)
        -- copas wraps socket ops in copas.try and raises on conditions like
        -- 'wantread' or 'unexpected eof while reading' when the telegram
        -- server closes the long-poll connection at the exact timeout
        -- boundary. without pcall those errors escape the coroutine, kill
        -- the polling thread, and crash the bot. cf. issue #46.
        local pok, success, res = pcall(copas_http.request, {
            ['url'] = endpoint,
            ['method'] = 'POST',
            ['headers'] = {
                ['Content-Type'] = 'multipart/form-data; boundary=' .. boundary,
                ['Content-Length'] = #body
            },
            ['source'] = ltn12.source.string(body),
            ['sink'] = ltn12.sink.table(response)
        })
        if not pok then
            print('Connection error [' .. tostring(success) .. ']')
            return false, success
        end
        if not success then
            print('Connection error [' .. tostring(res) .. ']')
            return false, res
        end
        local jstr = table.concat(response)
        local jdat = json.decode(jstr)
        if not jdat then
            return false, { ['ok'] = false, ['description'] = 'failed to decode API response', ['body'] = jstr }
        elseif not jdat.ok then
            if api.debug then
                local output = '\n' .. tostring(jdat.description) .. ' [' .. tostring(jdat.error_code) .. ']\n'
                print(output)
            end
            return false, jdat
        end
        return jdat, res
    end

    --- send an async request under the shared retry policy (api.retry).
    -- uses copas.sleep so honouring 429 / backing off never blocks the loop.
    function api.async.request(endpoint, parameters, file)
        return api._with_retry(function()
            return api.async._http_request(endpoint, parameters, file)
        end, function(seconds) copas.sleep(seconds) end)
    end

    --- run the bot with concurrent update processing.
    -- each update is dispatched to its own coroutine so a slow handler
    -- won't block processing of other updates.
    -- @param opts table polling options (limit, timeout, offset, allowed_updates)
    function api.async.run(opts)
        opts = opts or {}
        local limit = tonumber(opts.limit) or 1
        local timeout = tonumber(opts.timeout) or 0
        local offset = tonumber(opts.offset) or 0
        local allowed_updates = opts.allowed_updates

        -- Swap request function to use async version within copas context
        local sync_request = api.request
        api.request = api.async.request
        api.async._running = true

        -- backoff state for transient polling failures: start at 1s, double
        -- on each consecutive failure up to 30s, reset on the next success.
        -- prevents a hot loop when telegram is unreachable or the long-poll
        -- keeps eof'ing.
        local backoff = 1
        local max_backoff = 30

        copas.addthread(function()
            while api.async._running do
                local pok, updates, perr = pcall(api.get_updates, {
                    timeout = timeout,
                    offset = offset,
                    limit = limit,
                    allowed_updates = allowed_updates
                })
                if not pok then
                    if api.debug then
                        print('Polling error [' .. tostring(updates) .. '], backing off ' .. backoff .. 's')
                    end
                    copas.sleep(backoff)
                    backoff = math.min(backoff * 2, max_backoff)
                elseif updates and type(updates) == 'table' and updates.result then
                    backoff = 1
                    for _, v in ipairs(updates.result) do
                        -- each update gets its own coroutine
                        copas.addthread(function()
                            local ok, err = pcall(api.process_update, v)
                            if not ok and api.debug then
                                print('Update handler error: ' .. tostring(err))
                            end
                        end)
                        offset = v.update_id + 1
                        if api.metrics then api.metrics.incr('updates') end
                    end
                else
                    -- get_updates returned false or a malformed payload. back
                    -- off so a sustained server-side error doesn't pin a cpu.
                    -- a 409 is a configuration error (duplicate poller / webhook
                    -- still set), not transient, so surface it loudly.
                    if type(perr) == 'table' and tonumber(perr.error_code) == 409 then
                        api.log.warn('polling conflict (409): another getUpdates is running for ' ..
                            'this bot, or a webhook is still set. stop the other instance or call ' ..
                            'api.delete_webhook().')
                    elseif api.debug then
                        print('Polling returned no result, backing off ' .. backoff .. 's')
                    end
                    copas.sleep(backoff)
                    backoff = math.min(backoff * 2, max_backoff)
                end
            end
        end)

        copas.loop()

        -- Restore sync request when loop exits
        api.request = sync_request
        api.async._running = false
    end

    --- stop the async run loop.
    function api.async.stop()
        api.async._running = false
    end

    --- run multiple functions concurrently and collect results.
    -- each function runs in its own coroutine. returns when all complete.
    -- @param fns table array of functions to execute in parallel
    -- @return table results in order: { {value, ...}, {false, error}, ... }
    function api.async.all(fns)
        if not fns or #fns == 0 then
            return {}
        end

        local results = {}
        local remaining = #fns

        -- If already inside copas, use semaphore for synchronization
        local in_copas = type(copas.running) == 'function' and copas.running() or copas.running
        if in_copas then
            for i, fn in ipairs(fns) do
                copas.addthread(function()
                    results[i] = {pcall(fn)}
                    remaining = remaining - 1
                end)
            end
            -- Yield until all tasks complete
            while remaining > 0 do
                copas.pause()
            end
        else
            -- Not in copas context: start a mini loop
            for i, fn in ipairs(fns) do
                copas.addthread(function()
                    results[i] = {pcall(fn)}
                end)
            end
            copas.loop()
        end

        -- Unwrap results: if pcall succeeded, return the values directly
        local unwrapped = {}
        for i, r in ipairs(results) do
            if r[1] then
                -- pcall success: remove the true and return values
                unwrapped[i] = { select(2, (table.unpack or unpack)(r)) }
            else
                -- pcall failure: return false and the error
                unwrapped[i] = { false, r[2] }
            end
        end
        return unwrapped
    end

    --- spawn a background coroutine within the copas event loop.
    -- @param fn function the function to run in a new coroutine
    -- @return thread the copas thread
    function api.async.spawn(fn)
        return copas.addthread(fn)
    end

    --- non-blocking sleep (only works within a copas coroutine).
    -- @param seconds number duration to sleep
    function api.async.sleep(seconds)
        copas.sleep(seconds)
    end

    --- check if we're currently inside the async event loop.
    -- @return boolean true if the async loop is active
    function api.async.is_running()
        return api.async._running
    end
end
