# Native Lua MTProto wallet (work in progress)

The wallet API is declared from the pinned Telegram TL schema and encoded in Lua. The MTProto transport, auth-key handshake, AES-IGE encryption, encrypted RPC envelope, phone-code login, 2FA SRP proof, and encrypted session file also run in Lua using LuaSocket and luaossl. There is no Python process or local HTTP bridge.

This code is experimental and has not been interoperability-tested against Telegram. Result decoding is incomplete for Telegram's generated objects (for example users, chats, and NFT documents), so every result also retains its exact raw TL bytes and some decoded data may be absent. Do not use transfer, recovery, backup, or TON Connect calls with funds until the entire result schema and live API behavior have been validated.

## Dependencies

Install the package dependencies from the project rockspec, including LuaSocket and luaossl. MTProto requires a Telegram app `api_id` and `api_hash` from [my.telegram.org](https://my.telegram.org), plus a data center host and port.

## Current API shape

```lua
local Wallet = require('titogramlua.mtproto_wallet')
local wallet = Wallet.new({
    api_id = assert(tonumber(os.getenv('TELEGRAM_API_ID'))),
    api_hash = assert(os.getenv('TELEGRAM_API_HASH')),
    dc_id = 2,
    host = '149.154.167.40',
    port = 443,
})

local auth_key, err = wallet:connect()
if not auth_key then error(err) end
local sent_code, code_err = wallet:send_code('+201000000000')
if not sent_code then error(code_err.message or code_err) end
local login, login_err = wallet:sign_in(assert(os.getenv('TELEGRAM_LOGIN_CODE')),
    sent_code.phone_code_hash)
if not login and login_err.two_factor_required then
    login, login_err = wallet:check_password(assert(os.getenv('TELEGRAM_2FA_PASSWORD')))
end
if not login then error(login_err.message or login_err) end
assert(wallet:is_authorized())
assert(wallet:save_session('telegram-wallet.session', assert(os.getenv('SESSION_PASSWORD'))))

local state, state_err = wallet:get_state()
if not state then error(state_err.message or state_err) end
print('Wallet result:', state.data and state.data.address)
wallet:close()
```

To reopen the encrypted session, use `Wallet.load_session(options, path, password)`, then call `connect()`. Use `Wallet.objects` to build supported nested values such as `input_user_self()`, `input_user(id, access_hash)`, and ownership proofs. Results have `raw`, `constructor`, and `data` fields; `data` is decoded for the supported custom wallet types and is `nil` with `decoding_error` when the exact type is not implemented. Preserve raw results when writing application logic for unsupported constructors.

## Security

An MTProto auth key is a credential. Session files are encrypted with AES-256-CBC and authenticated with HMAC-SHA-256 using a PBKDF2-HMAC-SHA-512 key derived from the session password. Choose a long unique password and keep it private. Recovery methods can return secret material, and transfer methods can move funds. The present implementation has not completed live interoperability validation and must not be treated as production ready.

