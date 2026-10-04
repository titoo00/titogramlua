# Telegram user accounts (MTProto)

The normal `require('titogramlua')` client continues to use Telegram's HTTP Bot API and bot tokens. For a Telegram **user account**, this release provides the separate optional `require('titogramlua.methods.userbot')` client backed by TDLib, Telegram's client library. It does not implement the MTProto cryptography itself.

The entry point lives in `src/methods/userbot.lua`. Its operations are kept in separate files under `src/methods/userbot/`: `send.lua`, `execute.lua`, `receive.lua`, `run.lua`, `stop.lua`, and `close.lua`.

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
    io.stderr:write('TDLib JSON error: ', tostring(err), '\n')
end

user:run()
```

For a production application, replace terminal input with a private prompt and cover any additional authorization states required by the account (for example, email verification). Never log or commit phone numbers, login codes, two-step verification passwords, API hashes, or the database encryption key. The TDLib database contains the account session and must be kept private; `user:close()` closes the native client but leaves that database in place.

## Calling TDLib methods

`client:send(method, params)` sends any method supported by the installed TDLib version and returns its request ID. Responses and updates arrive through `on_update(update, client)`; each response retains its `@extra` request ID. All method names and object type names use TDLib's camelCase / `@type` schema.

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

## Bot API and user accounts are different clients

Do not pass a user phone number or MTProto credentials to `require('titogramlua').configure()`: that function takes a BotFather token. Use the separate TDLib client for a user session. Keep sessions isolated per account and follow Telegram's API terms and rate limits.
