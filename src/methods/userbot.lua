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
    client.send_message = require('titogramlua.methods.userbot.send_message')
    client.send_photo = require('titogramlua.methods.userbot.send_photo')
    client.edit_message_text = require('titogramlua.methods.userbot.edit_message_text')
    client.delete_messages = require('titogramlua.methods.userbot.delete_messages')
    client.get_chat = require('titogramlua.methods.userbot.get_chat')
    client.get_chats = require('titogramlua.methods.userbot.get_chats')
    client.get_message = require('titogramlua.methods.userbot.get_message')
    client.get_messages = require('titogramlua.methods.userbot.get_messages')
    client.search_messages = require('titogramlua.methods.userbot.search_messages')
    client.upload_story = require('titogramlua.methods.userbot.upload_story')
    client.send_story = require('titogramlua.methods.userbot.send_story')
    client.get_story = require('titogramlua.methods.userbot.get_story')
    client.get_stories = require('titogramlua.methods.userbot.get_stories')
    client.get_all_stories = require('titogramlua.methods.userbot.get_all_stories')
    client.get_chat_active_stories = require('titogramlua.methods.userbot.get_chat_active_stories')
    client.get_chat_stories = require('titogramlua.methods.userbot.get_chat_stories')
    client.get_archived_stories = require('titogramlua.methods.userbot.get_archived_stories')
    client.get_pinned_stories = require('titogramlua.methods.userbot.get_pinned_stories')
    client.get_story_views = require('titogramlua.methods.userbot.get_story_views')
    client.can_post_stories = require('titogramlua.methods.userbot.can_post_stories')
    client.enable_stealth_mode = require('titogramlua.methods.userbot.enable_stealth_mode')
    client.read_chat_stories = require('titogramlua.methods.userbot.read_chat_stories')
    client.view_stories = require('titogramlua.methods.userbot.view_stories')
    client.hide_chat_stories = require('titogramlua.methods.userbot.hide_chat_stories')
    client.show_chat_stories = require('titogramlua.methods.userbot.show_chat_stories')
    client.pin_chat_stories = require('titogramlua.methods.userbot.pin_chat_stories')
    client.unpin_chat_stories = require('titogramlua.methods.userbot.unpin_chat_stories')
    client.delete_stories = require('titogramlua.methods.userbot.delete_stories')
    client.delete_story = require('titogramlua.methods.userbot.delete_story')
    client.edit_story = require('titogramlua.methods.userbot.edit_story')
    client.edit_story_caption = require('titogramlua.methods.userbot.edit_story_caption')
    client.edit_story_media = require('titogramlua.methods.userbot.edit_story_media')
    client.edit_story_privacy = require('titogramlua.methods.userbot.edit_story_privacy')
    client.copy_story = require('titogramlua.methods.userbot.copy_story')
    client.forward_story = require('titogramlua.methods.userbot.forward_story')
    client.set_story_privacy_settings = require('titogramlua.methods.userbot.set_story_privacy_settings')
    client.block_user = require('titogramlua.methods.userbot.block_user')
    client.check_username = require('titogramlua.methods.userbot.check_username')
    client.delete_profile_photos = require('titogramlua.methods.userbot.delete_profile_photos')
    client.get_chat_audios = require('titogramlua.methods.userbot.get_chat_audios')
    client.get_chat_audios_count = require('titogramlua.methods.userbot.get_chat_audios_count')
    client.get_chat_photos = require('titogramlua.methods.userbot.get_chat_photos')
    client.get_chat_photos_count = require('titogramlua.methods.userbot.get_chat_photos_count')
    client.get_common_chats = require('titogramlua.methods.userbot.get_common_chats')
    client.get_default_emoji_statuses = require('titogramlua.methods.userbot.get_default_emoji_statuses')
    client.get_me = require('titogramlua.methods.userbot.get_me')
    client.get_users = require('titogramlua.methods.userbot.get_users')
    client.set_emoji_status = require('titogramlua.methods.userbot.set_emoji_status')
    client.set_personal_channel = require('titogramlua.methods.userbot.set_personal_channel')
    client.set_profile_photo = require('titogramlua.methods.userbot.set_profile_photo')
    client.set_username = require('titogramlua.methods.userbot.set_username')
    client.unblock_user = require('titogramlua.methods.userbot.unblock_user')
    client.update_birthday = require('titogramlua.methods.userbot.update_birthday')
    client.update_profile = require('titogramlua.methods.userbot.update_profile')
    client.update_status = require('titogramlua.methods.userbot.update_status')
    client.add_profile_audio = require('titogramlua.methods.userbot.add_profile_audio')
    client.remove_profile_audio = require('titogramlua.methods.userbot.remove_profile_audio')
    client.set_profile_audio_position = require('titogramlua.methods.userbot.set_profile_audio_position')
    client.get_account_ttl = require('titogramlua.methods.userbot.get_account_ttl')
    client.set_account_ttl = require('titogramlua.methods.userbot.set_account_ttl')
    client.set_inactive_session_ttl = require('titogramlua.methods.userbot.set_inactive_session_ttl')
    client.get_privacy = require('titogramlua.methods.userbot.get_privacy')
    client.set_privacy = require('titogramlua.methods.userbot.set_privacy')
    client.get_global_privacy_settings = require('titogramlua.methods.userbot.get_global_privacy_settings')
    client.set_global_privacy_settings = require('titogramlua.methods.userbot.set_global_privacy_settings')

    return client
end

return user
