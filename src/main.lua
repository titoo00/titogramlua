--[[

       _       _                                      _           _          _
      | |     | |                                    | |         | |        | |
      | |_ ___| | ___  __ _ _ __ __ _ _ __ ___ ______| |__   ___ | |_ ______| |_   _  __ _
      | __/ _ \ |/ _ \/ _` | '__/ _` | '_ ` _ \______| '_ \ / _ \| __|______| | | | |/ _` |
      | ||  __/ |  __/ (_| | | | (_| | | | | | |     | |_) | (_) | |_       | | |_| | (_| |
       \__\___|_|\___|\__, |_|  \__,_|_| |_| |_|     |_.__/ \___/ \__|      |_|\__,_|\__,_|
                       __/ |
                      |___/

      Version 3.7-0
      Copyright (c) 2017-2026 Matthew Hesketh
      See LICENSE for details

]]

--- telegram-bot-lua - a feature-filled telegram bot API library.
-- supports bot API 10.1 with full method coverage, a command router, sessions
-- and conversations, a webhook receiver, flood-control retries, middleware,
-- async polling, structured logging, an MCP server, adapters, and
-- backward-compatible v2 shims.
-- @module telegram-bot-lua
-- @author Matthew Hesketh
-- @license GPL-3
-- @copyright 2017-2026

local api = {}
local https = require('ssl.https')
local multipart = require('multipart-post')
local ltn12 = require('ltn12')
local json = require('dkjson')
local config = require('telegram-bot-lua.config')

api.version = '3.7-0'

--- configure the bot with a token and optional debug mode.
-- connects to the telegram API and retrieves bot info via getMe.
-- @param token string the bot API token from @BotFather
-- @param debug boolean enable debug logging of requests
-- @return table the api object, configured and ready to use
function api.configure(token, debug)
    if not token or type(token) ~= 'string' then
        token = nil
    end
    api.debug = debug and true or false
    api.token = assert(token, 'Please specify your bot API token you received from @BotFather!')
    local max_retries = 5
    for i = 1, max_retries do
        api.info = api.get_me()
        if api.info and api.info.result then
            break
        end
        if i == max_retries then
            error('Failed to connect to Telegram API after ' .. max_retries .. ' attempts. Check your token and network.')
        end
        if _G._TEST then break end
        os.execute('sleep 1')
    end
    if api.info and api.info.result then
        api.info = api.info.result
        api.info.name = api.info.first_name
    end
    return api
end

--- send a request to the telegram bot API.
-- encodes parameters as multipart form data and handles file uploads.
-- @param endpoint string the full API endpoint URL
-- @param parameters table optional request parameters
-- @param file table optional file attachments keyed by type
-- @return table|false the decoded JSON response, or false on failure
-- @return string|table the HTTP status or error details
function api._http_request(endpoint, parameters, file)
    assert(endpoint, 'You must specify an endpoint to make this request to!')
    parameters = parameters or {}
    -- work on a shallow copy so we never mutate the caller's table; stringify
    -- scalars for multipart encoding but leave tables (file parts) untouched.
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
    -- luasec can raise on transient ssl / socket faults (peer closed mid-read,
    -- handshake aborted, dns blip). historically these propagated as lua errors
    -- and tore down the polling loop. wrap so the caller always gets a
    -- (false, err) return and can decide whether to retry.
    local pok, success, res = pcall(https.request, {
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
        api.log.warn('connection error:', success)
        return false, success
    end
    if not success then
        api.log.warn('connection error:', res)
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

--- retry policy for api.request. honours telegram's 429 retry_after (required
-- by the api) and retries transient connection failures with bounded
-- exponential backoff; a normal 4xx api error is returned immediately.
api.retry = {
    ['enabled'] = true,
    ['max_attempts'] = 3,
    ['base_delay'] = 1,
    ['max_delay'] = 30
}

-- default blocking sleeper; the async layer passes copas.sleep instead.
local function blocking_sleep(seconds)
    local ok, socket = pcall(require, 'socket')
    if ok and socket and socket.sleep then
        socket.sleep(seconds)
    else
        os.execute('sleep ' .. tostring(math.max(1, math.floor(seconds))))
    end
end

-- classify a request error: 'rate_limit' (+ retry_after), 'transient', or 'fatal'.
-- an api error with a numeric error_code other than 429 is fatal (not retried);
-- 429 is rate-limited; string connection / json-decode errors are transient.
local function classify_error(err)
    if type(err) == 'table' and tonumber(err.error_code) then
        if tonumber(err.error_code) == 429 then
            local retry_after = err.parameters and tonumber(err.parameters.retry_after)
            return 'rate_limit', retry_after
        end
        return 'fatal'
    end
    return 'transient'
end

--- run a request thunk under the retry policy in api.retry.
-- @param thunk function a no-arg function returning (result, err) like api.request
-- @param sleeper function optional sleep(seconds); defaults to a blocking sleep
-- @return table|false result and error, identical to the thunk's contract
function api._with_retry(thunk, sleeper)
    sleeper = sleeper or blocking_sleep
    if not (api.retry and api.retry.enabled) then
        return thunk()
    end
    local max_attempts = tonumber(api.retry.max_attempts) or 3
    local backoff = tonumber(api.retry.base_delay) or 1
    local max_delay = tonumber(api.retry.max_delay) or 30
    local attempt = 0
    while true do
        attempt = attempt + 1
        local result, err = thunk()
        if result then
            return result, err
        end
        local kind, retry_after = classify_error(err)
        if kind == 'fatal' or attempt >= max_attempts then
            return result, err
        end
        if kind == 'rate_limit' then
            sleeper(retry_after or backoff)
        else
            sleeper(backoff)
            backoff = math.min(backoff * 2, max_delay)
        end
    end
end

--- send a request to the telegram bot API with the retry policy applied.
-- wraps api._http_request; see api.retry to configure or disable retries.
-- @param endpoint string the full API endpoint URL
-- @param parameters table optional request parameters
-- @param file table optional file attachments keyed by type
-- @return table|false the decoded JSON response, or false on failure
-- @return string|table the HTTP status or error details
function api.request(endpoint, parameters, file)
    return api._with_retry(function()
        return api._http_request(endpoint, parameters, file)
    end)
end

--- get basic information about the bot via getMe.
-- @return table|false the bot user object, or false on failure
-- @return string|table the HTTP status or error details
function api.get_me()
    local success, res = api.request(config.endpoint .. api.token .. '/getMe')
    return success, res
end

--- log the bot out from the cloud bot API server.
-- @return table|false true on success, or false on failure
-- @return string|table the HTTP status or error details
function api.log_out()
    local success, res = api.request(config.endpoint .. api.token .. '/logOut')
    return success, res
end

--- close the bot instance before moving it to a local server.
-- @return table|false true on success, or false on failure
-- @return string|table the HTTP status or error details
function api.close()
    local success, res = api.request(config.endpoint .. api.token .. '/close')
    return success, res
end

-- load all modules
require('telegram-bot-lua.log')(api)
require('telegram-bot-lua.middleware')(api)
require('telegram-bot-lua.handlers')(api)
require('telegram-bot-lua.builders')(api)
require('telegram-bot-lua.builders_rich')(api)
require('telegram-bot-lua.helpers')(api)
require('telegram-bot-lua.session')(api)
require('telegram-bot-lua.framework')(api)
require('telegram-bot-lua.methods.updates')(api)
require('telegram-bot-lua.methods.messages')(api)
require('telegram-bot-lua.methods.chat')(api)
require('telegram-bot-lua.methods.members')(api)
require('telegram-bot-lua.methods.forum')(api)
require('telegram-bot-lua.methods.stickers')(api)
require('telegram-bot-lua.methods.inline')(api)
require('telegram-bot-lua.methods.payments')(api)
require('telegram-bot-lua.methods.games')(api)
require('telegram-bot-lua.methods.passport')(api)
require('telegram-bot-lua.methods.bot')(api)
require('telegram-bot-lua.methods.gifts')(api)
require('telegram-bot-lua.methods.checklists')(api)
require('telegram-bot-lua.methods.stories')(api)
require('telegram-bot-lua.methods.business')(api)
require('telegram-bot-lua.methods.suggested_posts')(api)
require('telegram-bot-lua.methods.rich')(api)
require('telegram-bot-lua.utils')(api)
require('telegram-bot-lua.mcp')(api)
require('telegram-bot-lua.async')(api)
require('telegram-bot-lua.webhook')(api)
require('telegram-bot-lua.adapters')(api)
require('telegram-bot-lua.compat')(api)

return api
