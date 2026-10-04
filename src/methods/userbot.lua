--- optional Telegram user-account client backed by TDLib.
-- This module is deliberately separate from the Bot API client in
-- `titogramlua`. It loads a locally installed TDLib JSON shared library using
-- LuaJIT FFI and forwards TDLib requests and updates as Lua tables.
-- @module titogramlua.methods.userbot

local json = require('dkjson')
local mime = require('mime')

local user = {}

local function required_string(opts, name)
    local value = opts[name]
    assert(type(value) == 'string' and value ~= '', name .. ' must be a non-empty string')
    return value
end

local function load_tdjson(ffi, path)
    if path then
        local ok, lib = pcall(ffi.load, path)
        if ok then return lib end
        error('could not load TDLib JSON library at ' .. path .. ': ' .. tostring(lib), 3)
    end

    local names = package.config:sub(1, 1) == '\\'
        and {'tdjson', 'tdjson.dll'}
        or {'tdjson', 'libtdjson.so', 'libtdjson.dylib'}
    local errors = {}
    for _, name in ipairs(names) do
        local ok, lib = pcall(ffi.load, name)
        if ok then return lib end
        errors[#errors + 1] = name .. ': ' .. tostring(lib)
    end
    error('TDLib JSON library was not found; install TDLib or set opts.library. Tried: '
        .. table.concat(errors, '; '), 3)
end

--- create a TDLib-backed user client.
-- Requires LuaJIT, the TDLib JSON shared library, and api_id/api_hash from
-- https://my.telegram.org. The TDLib database is encrypted with encryption_key.
-- @param opts table configuration; api_id, api_hash, database_directory,
--   encryption_key are required; files_directory and library are optional.
-- @return table user client
function user.new(opts)
    assert(type(opts) == 'table', 'opts table is required')
    local ok, ffi = pcall(require, 'ffi')
    assert(ok, 'titogramlua.methods.userbot requires LuaJIT (LuaJIT FFI is unavailable)')

    pcall(ffi.cdef, [[
        void *td_json_client_create(void);
        void td_json_client_send(void *client, const char *request);
        const char *td_json_client_receive(void *client, double timeout);
        const char *td_json_client_execute(void *client, const char *request);
        void td_json_client_destroy(void *client);
        void td_set_log_verbosity_level(int level);
    ]])

    local lib = load_tdjson(ffi, opts.library)
    local api_id = tonumber(opts.api_id)
    assert(api_id and api_id > 0 and api_id == math.floor(api_id), 'api_id must be a positive integer')
    local api_hash = required_string(opts, 'api_hash')
    local database_directory = required_string(opts, 'database_directory')
    local encryption_key = required_string(opts, 'encryption_key')

    if opts.log_verbosity_level ~= nil then
        lib.td_set_log_verbosity_level(tonumber(opts.log_verbosity_level) or 2)
    end

    local handle = lib.td_json_client_create()
    assert(handle ~= nil, 'TDLib failed to create a client')

    local client = {
        _ffi = ffi,
        _lib = lib,
        _handle = handle,
        _next_id = 0,
        _running = false,
        _closed = false,
        _opts = opts,
        _tdlib_parameters = {
            ['@type'] = 'setTdlibParameters',
            use_test_dc = opts.use_test_dc == true,
            database_directory = database_directory,
            files_directory = opts.files_directory or database_directory,
            database_encryption_key = mime.b64(encryption_key),
            use_file_database = opts.use_file_database ~= false,
            use_chat_info_database = opts.use_chat_info_database ~= false,
            use_message_database = opts.use_message_database ~= false,
            use_secret_chats = opts.use_secret_chats == true,
            api_id = api_id,
            api_hash = api_hash,
            system_language_code = opts.system_language_code or 'en',
            device_model = opts.device_model or 'titogramlua',
            system_version = opts.system_version or 'unknown',
            application_version = opts.application_version or '3.7.0'
        },
        _encryption_key = encryption_key
    }

    client.send = require('titogramlua.methods.userbot.send')
    client.execute = require('titogramlua.methods.userbot.execute')
    client.receive = require('titogramlua.methods.userbot.receive')
    client.run = require('titogramlua.methods.userbot.run')
    client.stop = require('titogramlua.methods.userbot.stop')
    client.close = require('titogramlua.methods.userbot.close')

    return client
end

return user
