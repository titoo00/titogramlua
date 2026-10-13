# Direct MTProto wallet bridge

This optional bridge exposes RavenGram's raw Telegram wallet MTProto methods to Lua. It runs separately from TitogramLua's TDLib userbot and creates a separate RavenGram session.

## Install and start

Install Python 3.10 or newer and RavenGram:

    python -m pip install "Ravengram @ git+https://github.com/ahmedahah4/ravengram.git@f893483d9a6ce8cc7e2322a1fee65a1692eed384"

Set Telegram app credentials from https://my.telegram.org and a private bridge token. Generate the token with a cryptographically secure random generator. Never commit or share these values.

    export TELEGRAM_API_ID="your-api-id"
    export TELEGRAM_API_HASH="your-api-hash"
    export TITOGRAM_WALLET_BRIDGE_TOKEN="a-random-secret-at-least-32-characters"
    python examples/mtproto-wallet/bridge.py

At first start, RavenGram may ask you to sign in in the terminal. Its SQLite session is stored separately from TDLib under `~/.local/share/titogramlua-wallet` by default; set `RAVENGRAM_SESSION_DIR` to choose another directory. The session file contains the MTProto authorization key and is **not encrypted at rest**. The bridge creates the directory with owner-only permissions on Unix; on Windows, keep it under your private user profile. Treat the session file like a login credential. The bridge binds only to 127.0.0.1 on port 8765.

## Call from Lua

    local Wallet = require('titogramlua.mtproto_wallet')
    local wallet = Wallet.new({
        url = 'http://127.0.0.1:8765/rpc',
        token = assert(os.getenv('TITOGRAM_WALLET_BRIDGE_TOKEN')),
    })

    local state, err = wallet:get_state()
    if not state then error(err.message) end
    print('TON balance (nanotons):', state.balance)
    print('Wallet address:', state.address)

    local page, page_err = wallet:get_transactions({
        inbound = true,
        outbound = true,
        offset = '',
        limit = 20,
    })
    if not page then error(page_err.message) end

Convenience methods cover all wallet functions in the RavenGram schema: wallet state and addresses, transaction lists and lookup, wallet replacement and backup controls, proof challenges, transfers, gasless information, NFTs, and TON Connect sessions and requests. Each accepts a table of raw MTProto fields. You can also call wallet:call('wallet.getState', params).

Nested TL objects use tables such as {['@type'] = 'inputUserSelf'}. Binary bytes use {['@bytes'] = 'BASE64'} and binary results use the same tagged form.

## Security and limits

- This is a direct MTProto user-account client. It needs a separate login and encrypted session; it cannot reuse the TDLib database.
- The bearer token protects the loopback bridge. Do not expose port 8765 to the internet or log request and response bodies.
- Wallet methods can move funds or return recovery material. Call only methods you understand, and never log or share secret phrase results or transaction payloads.
- Telegram validates wallet permissions and requests. A successful RPC response does not guarantee that an on-chain transaction has settled.
