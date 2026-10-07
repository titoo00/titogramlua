# Telegram user accounts (MTProto)

The normal `require('titogramlua')` client continues to use Telegram's HTTP Bot API and bot tokens. For a Telegram **user account**, this release provides the separate optional `require('titogramlua.methods.userbot')` client backed by TDLib, Telegram's client library. It does not implement the MTProto cryptography itself.

The entry point lives in `src/methods/userbot.lua`. Every operation has its own file under `src/methods/userbot/`, named after the Lua method. Each module documents its arguments and a usage example.

## Requirements

- LuaJIT (the module uses LuaJIT FFI; the normal Bot API client remains usable with Lua 5.1–5.5)
- A locally installed TDLib JSON shared library (`tdjson.dll`, `libtdjson.so`, or `libtdjson.dylib`)
- An `api_id` and `api_hash` from [my.telegram.org](https://my.telegram.org)
- A private database directory and a strong, private TDLib database encryption key

TDLib is a native dependency and is not installed by LuaRocks. If the library is outside the system library search path, provide its path in `library`.

## Create a client

```lua
local user = require('titogramlua.methods.userbot').new({
    api_id = tonumber(os.getenv('TELEGRAM_API_ID')),
    api_hash = assert(os.getenv('TELEGRAM_API_HASH')),
    database_directory = './private/telegram-user-db',
    files_directory = './private/telegram-files',
    encryption_key = assert(os.getenv('TELEGRAM_DB_KEY')),
    -- library = '/path/to/libtdjson.so', -- optional
})

user.on_auth_state = function(state, client)
    local kind = state['@type']
    if kind == 'authorizationStateWaitPhoneNumber' then
        -- Collect the account phone number through your own trusted UI.
        client:send('setAuthenticationPhoneNumber', {
            phone_number = assert(os.getenv('TELEGRAM_PHONE_NUMBER')),
        })
    elseif kind == 'authorizationStateWaitCode' then
        -- Do not hard-code login codes. Read them from a private prompt.
        io.write('Telegram login code: ')
        client:send('checkAuthenticationCode', {code = assert(io.read('*l'))})
    elseif kind == 'authorizationStateWaitPassword' then
        io.write('Telegram two-step verification password: ')
        client:send('checkAuthenticationPassword', {password = assert(io.read('*l'))})
    end
end

user.on_message = function(message)
    if message.content and message.content['@type'] == 'messageText' then
        print(message.chat_id, message.content.text.text)
    end
end

user.on_error = function(err)
    io.stderr:write('TDLib error: ', type(err) == 'table' and err.message or tostring(err), '\n')
end

user:run()
```

For a production application, replace terminal input with a private prompt and cover any additional authorization states required by the account (for example, email verification). Never log or commit phone numbers, login codes, two-step verification passwords, API hashes, or the database encryption key. The TDLib database contains the account session and must be kept private; `user:close()` closes the native client but leaves that database in place.

## Named methods

The client includes named wrappers for common chat, message, and story operations. Each wrapper returns the request ID from `client:send`; TDLib results arrive later through `on_update`.

| Lua method | File | Use |
| --- | --- | --- |
| `send_message(chat_id, text, opts)` | `send_message.lua` | Send formatted text, optionally to a topic or as a reply. |
| `send_photo(chat_id, photo, opts)` | `send_photo.lua` | Send a photo using a TDLib `InputFile` object. |
| `edit_message_text(chat_id, message_id, text, opts)` | `edit_message_text.lua` | Edit a text message. |
| `delete_messages(chat_id, message_ids, revoke)` | `delete_messages.lua` | Delete messages, optionally for everyone when allowed. |
| `get_chat(chat_id)` / `get_chats(chat_list, limit)` | `get_chat.lua` / `get_chats.lua` | Read chat details or a page of chats. |
| `get_message(chat_id, message_id)` / `get_messages(chat_id, ids)` | `get_message.lua` / `get_messages.lua` | Read one or several messages. |
| `search_messages(params)` | `search_messages.lua` | Search using TDLib `searchMessages` fields. |
| `upload_story(chat_id, content, opts)` | `upload_story.lua` | Post a photo or video story with an explicit privacy setting. |
| `send_story(chat_id, content, opts)` | `send_story.lua` | Alias of `upload_story`; takes TDLib story content and options. |
| `get_story(poster_chat_id, story_id)` | `get_story.lua` | Read a story. |
| `get_stories(poster_chat_id, story_ids)` | `get_stories.lua` | Get one or more story IDs; multiple requests return multiple request IDs. |
| `get_all_stories(story_list)` | `get_all_stories.lua` | Ask TDLib to load the main or archive story list. |
| `get_chat_active_stories(chat_id)` | `get_chat_active_stories.lua` | List a chat's active stories. |
| `get_chat_stories(chat_id)` | `get_chat_stories.lua` | Alias of `get_chat_active_stories`. |
| `get_archived_stories(chat_id, from_story_id, limit)` | `get_archived_stories.lua` | Read an archived story page where the account has access. |
| `get_pinned_stories(chat_id, from_story_id, limit)` | `get_pinned_stories.lua` | Read chat-page stories; Telegram returns pinned stories first. |
| `get_story_views(story_id, opts)` | `get_story_views.lua` | Get story interactions for a story posted by the current account. |
| `can_post_stories(chat_id)` / `enable_stealth_mode()` | `can_post_stories.lua` / `enable_stealth_mode.lua` | Check story posting rights or enable Premium stealth mode. |
| `read_chat_stories(poster_chat_id, story_id)` / `view_stories(poster_chat_id, story_ids)` | `read_chat_stories.lua` / `view_stories.lua` | Open stories so TDLib marks them as viewed. |
| `close_story(poster_chat_id, story_id)` | `close_story.lua` | Close a story after viewing it. |
| `hide_chat_stories(chat_id)` / `show_chat_stories(chat_id)` | `hide_chat_stories.lua` / `show_chat_stories.lua` | Remove stories from the main list or return them to it. |
| `pin_chat_stories(chat_id, story_ids)` / `unpin_chat_stories(chat_id, story_ids)` | `pin_chat_stories.lua` / `unpin_chat_stories.lua` | Replace the pinned list, or remove selected pins. Pass nil or `{}` to unpin all. |
| `delete_stories(poster_chat_id, story_ids)` | `delete_stories.lua` | Delete one or more stories, returning request IDs. |
| `delete_story(poster_chat_id, story_id)` | `delete_story.lua` | Delete a story when permitted. |
| `edit_story(poster_chat_id, story_id, content, opts)` | `edit_story.lua` | Edit a story when permitted. |
| `edit_story_caption(...)` / `edit_story_media(...)` / `edit_story_privacy(...)` | matching `edit_story_*.lua` | Edit captions, media, or privacy. Pass nil for content to preserve media when changing the caption. |
| `copy_story(chat_id, content, opts)` / `forward_story(chat_id, content, source, opts)` | matching `*_story.lua` | Copy supplied content without attribution, or repost it using a TDLib `storyFullId` source reference. |
| `set_story_privacy_settings(story_id, privacy_settings)` | `set_story_privacy_settings.lua` | Change story privacy when permitted. |
| `block_user(user_id)` / `unblock_user(user_id)` | `block_user.lua` / `unblock_user.lua` | Add or remove a user from the main block list. |
| `check_username(chat_id, username)` / `set_username(username)` | `check_username.lua` / `set_username.lua` | Check a chat username or change the account username. `check_username` follows TDLib chat rules and is not an account-username availability check. |
| `delete_profile_photos(photo_ids)` | `delete_profile_photos.lua` | Delete profile photos by ID; returns request IDs for the individual deletes. |
| `get_chat_audios(user_id, offset, limit)` / `get_chat_audios_count(user_id)` | `get_chat_audios.lua` / `get_chat_audios_count.lua` | Read a user's profile audio list. TDLib returns the total count alongside the list response. |
| `get_chat_photos(chat_id, limit, chat_history)` / `get_chat_photos_count(chat_id, chat_history)` | `get_chat_photos.lua` / `get_chat_photos_count.lua` | Read a user's profile photos, or chat-photo history when `chat_history` is true. |
| `get_common_chats(user_id, offset_chat_id, limit)` | `get_common_chats.lua` | Read groups shared with a user. |
| `get_default_emoji_statuses()` / `set_emoji_status(chat_id, emoji_status)` | `get_default_emoji_statuses.lua` / `set_emoji_status.lua` | List default status emojis or set/clear an account/chat emoji status. |
| `get_me()` / `get_users(user_ids)` | `get_me.lua` / `get_users.lua` | Read the current account or one/multiple users by ID. |
| `set_personal_channel(chat_id)` | `set_personal_channel.lua` | Set the personal chat/channel; omit the ID to remove it. |
| `set_profile_photo(photo, is_public)` | `set_profile_photo.lua` | Set a profile photo with a TDLib `InputChatPhoto` object. |
| `update_birthday(birthdate)` | `update_birthday.lua` | Set or clear the account birthday with a TDLib `birthdate` object. |
| `update_profile(fields)` | `update_profile.lua` | Update name and/or bio; supply both first and last name together when changing the name. |
| `update_status(offline)` | `update_status.lua` | Set the account online state via TDLib. |
| `add_profile_audio(audio, opts)` / `remove_profile_audio(audio_id)` / `set_profile_audio_position(audio_id, after_file_id)` | matching `*_profile_audio.lua` | Add an InputFile or inputAudio; remove/reorder by TDLib file ID. Use 0 to move to the beginning. |
| `get_account_ttl()` / `set_account_ttl(ttl)` / `set_inactive_session_ttl(days)` | matching TTL modules | Read/set account deletion and inactive session timeouts; `set_account_ttl` takes a TDLib `accountTtl` object. |
| `get_privacy(setting)` / `set_privacy(setting, rules)` / `get_global_privacy_settings()` / `set_global_privacy_settings(settings)` | matching privacy modules | Manage privacy rules and separate TDLib privacy groups; global helpers return a table of request IDs. |

### Send a message

```lua
local request_id = user:send_message(chat_id, 'Hello from my user account')
```

### Upload a story

Use a TDLib `inputStoryContentPhoto` or `inputStoryContentVideo` object. Pick privacy explicitly so a story is never made public by an implicit wrapper default. For the current account, pass its Saved Messages chat identifier as `chat_id`.

```lua
local request_id = user:upload_story(saved_messages_chat_id, {
    ['@type'] = 'inputStoryContentPhoto',
    photo = {['@type'] = 'inputFileLocal', path = './story.jpg'},
    added_sticker_file_ids = {},
}, {
    caption = 'A day out',
    privacy_settings = {
        ['@type'] = 'storyPrivacySettingsContacts',
        except_user_ids = {},
    },
    active_period = 86400,
})
```

The story operation maps to TDLib's `postStory`; TDLib returns the posted story asynchronously in updates.

## Calling any TDLib method

Use `request(method, params, callback)` to handle a specific response without
matching IDs yourself. The callback runs during `receive()` or `run()` and gets
`(result, nil, client)` on success or `(nil, error, client)` on failure. The response
also reaches `on_update`. `receive()` returns TDLib errors as its second result;
`run()` forwards them to `on_error`.

```lua
user:request('getMe', {}, function(result, err)
    if err then print(err.code, err.message) else print(result.id) end
end)
```

TDLib exposes global privacy through separate methods. For example:

```lua
local request_ids = user:get_global_privacy_settings()
-- Match request_ids.archive_chat_list/read_date/new_chat in on_update.
user:set_global_privacy_settings({
    read_date = {['@type'] = 'readDatePrivacySettings', show_read_date = false},
})
```

The setter accepts `archive_chat_list`, `read_date`, `new_chat`, and
`gift_settings`, each containing its complete TDLib settings object. Read the
current settings before replacing a group to preserve its other fields.
Selected-story unpinning first reads the pinned IDs, then sends the replacement
list during response handling; its returned ID belongs to the initial read.

These wrappers follow the [official TDLib schema](https://github.com/tdlib/td/blob/master/td/generate/scheme/td_api.tl).
Recent methods and the nested `inputPhoto`/`inputAudio` structures require a
TDLib build with the corresponding schema.

`client:send(method, params)` remains available for every method supported by the installed TDLib version, including methods that do not have a named wrapper yet. It returns its request ID. Responses and updates arrive through `on_update(update, client)`; each response retains its `@extra` request ID. All method names and object type names use TDLib's camelCase / `@type` schema.

```lua
user.on_update = function(update)
    if update['@type'] == 'error' then
        io.stderr:write(update.code, ': ', update.message, '\n')
    end
end

user:send('sendMessage', {
    chat_id = 123456789,
    input_message_content = {
        ['@type'] = 'inputMessageText',
        text = {['@type'] = 'formattedText', text = 'Hello from my user account', entities = {}},
    },
})
```

`client:execute(method, params)` is synchronous and should only be used for TDLib methods documented as locally executable. `client:receive(timeout)` processes a single update/response; `client:stop()` stops a running receive loop and `client:close()` releases the TDLib handle. Run one receive loop per client.

The methods above return the TDLib request ID (or a table of IDs for multi-request helpers). They do not block for Telegram's response. Use `on_update` to inspect the response, including `ChatPhotos`, `ChatAudios`, `Count`, and `Ok` objects. `get_chat_photos` distinguishes user profile photos from a group's photo-change history through its third `chat_history` argument. The user-method names mirror the referenced Pyrogram API where possible, but their parameters and response behavior follow TDLib.

## Bot API and user accounts are different clients

Do not pass a user phone number or MTProto credentials to `require('titogramlua').configure()`: that function takes a BotFather token. Use the separate TDLib client for a user session. Keep sessions isolated per account and follow Telegram's API terms and rate limits.

## Additional Ravengram adapters

See [the adapter catalog and compatibility notes](userbot-port.md) for all 439 source names, TDLib parameter conventions, event registration and asynchronous composed operations. The catalog has 438 covered names and one unsupported session-export feature; it does not claim Python signature or runtime equivalence.
