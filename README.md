# titogramlua

A feature-filled Telegram API library written in Lua, created by [Yosef](https://t.me/PTPUP). The default client supports Bot API 10.3 with full coverage of all available methods. An optional TDLib-backed user-account (MTProto) client is provided separately by `require('titogramlua.methods.userbot')`.

## Installation

Requires Lua 5.1+ and LuaRocks. LuaRocks installs the library's Lua dependencies (`dkjson`, `luasec`, `luasocket`, `multipart-post`, `luautf8`, and `copas`) automatically:

```
luarocks install titogramlua
```

### Complete installation on Ubuntu 22.04

The regular Bot API client needs Lua and LuaRocks. The optional user-account client additionally needs LuaJIT and the native TDLib JSON library; TDLib is built separately and is not installed by LuaRocks.

Install the library and its Lua dependencies:

```bash
sudo apt update
sudo apt install -y lua5.4 liblua5.4-dev luarocks build-essential libssl-dev zlib1g-dev
sudo luarocks --lua-version=5.4 install titogramlua
```

To use the optional TDLib-backed user-account client, install its build tools and LuaJIT. `gperf` is required during TDLib configuration (without it CMake stops before creating the build files):

```bash
sudo apt install -y git cmake gperf pkg-config libssl-dev zlib1g-dev build-essential lua5.1 liblua5.1-0-dev luajit libluajit-5.1-dev
```

Build and install TDLib's JSON shared library. Build all targets first (TDLib's install step also expects its static libraries to exist, so building only the `tdjson` target makes `cmake --install` fail with `file INSTALL cannot find ".../libtdjson_static.a"`), then install as root:

```bash
if [ ! -d ~/td/.git ]; then git clone https://github.com/tdlib/td.git ~/td; fi
cmake -S ~/td -B ~/td/build -DCMAKE_BUILD_TYPE=Release
cmake --build ~/td/build -j2
sudo cmake --install ~/td/build
sudo ldconfig
ldconfig -p | grep tdjson
```

Install titogramlua's Lua modules for LuaJIT's Lua 5.1 module ABI, then run user-account code with `luajit`:

```bash
sudo luarocks --lua-version=5.1 install titogramlua
luajit -e "require('titogramlua.methods.userbot'); print('userbot module loaded')"
```

The TDLib build follows [TDLib's official build instructions](https://github.com/tdlib/td#building). Building TDLib needs a lot of RAM: on lower-memory servers use `-j1` or `-j2` to limit parallel compilation, and add swap space if the build is killed. See [User accounts / MTProto](docs/userbot.md) for the complete user-account guide. Optional database adapters are not installed by default: SQLite uses `lsqlite3` (`sudo apt install libsqlite3-dev`, then `sudo luarocks --lua-version=5.4 install lsqlite3`); PostgreSQL uses `pgmoon` (`sudo luarocks --lua-version=5.4 install pgmoon`). Redis, LLM, and SMTP use the library's built-in Lua clients and need their service/API credentials.

For development and diagnosing library changes, install the optional project tools:

```bash
sudo luarocks --lua-version=5.4 install busted
sudo luarocks --lua-version=5.4 install luacheck
sudo luarocks --lua-version=5.4 install ldoc
```

Then run `busted --no-coverage -o utfTerminal` for tests, `luacheck src/ --no-unused-args --no-max-line-length --globals _G _TEST` for lint, or `make docs` to regenerate API documentation.

### User account (UserBot): login and first run

The UserBot is a separate TDLib client that signs into a Telegram **user account**. It does not use a BotFather token and does not replace the normal Bot API client. Get `api_id` and `api_hash` from [my.telegram.org](https://my.telegram.org), then set them and a persistent encryption key in the server environment. Keep the same key between runs so TDLib can reopen its encrypted session database:

```bash
export TELEGRAM_API_ID='YOUR_API_ID'
export TELEGRAM_API_HASH='YOUR_API_HASH'
export TELEGRAM_DB_KEY='A_LONG_RANDOM_SECRET_SAVED_PRIVATELY'
mkdir -p "$HOME/.local/share/titogramlua-userbot/db" "$HOME/.local/share/titogramlua-userbot/files"
chmod 700 "$HOME/.local/share/titogramlua-userbot" "$HOME/.local/share/titogramlua-userbot/db" "$HOME/.local/share/titogramlua-userbot/files"
```

Save these environment variables securely for future launches; do not commit them to GitHub or paste them into source code. Create `userbot.lua` with this minimal interactive login example:

```lua
local user = require('titogramlua.methods.userbot').new({
    api_id = assert(tonumber(os.getenv('TELEGRAM_API_ID')), 'set TELEGRAM_API_ID'),
    api_hash = assert(os.getenv('TELEGRAM_API_HASH'), 'set TELEGRAM_API_HASH'),
    database_directory = os.getenv('HOME') .. '/.local/share/titogramlua-userbot/db',
    files_directory = os.getenv('HOME') .. '/.local/share/titogramlua-userbot/files',
    encryption_key = assert(os.getenv('TELEGRAM_DB_KEY'), 'set TELEGRAM_DB_KEY'),
})

local function prompt(label)
    io.write(label)
    io.flush()
    return assert(io.read('*l'), 'could not read terminal input')
end

user.on_auth_state = function(state, client)
    local kind = state['@type']
    if kind == 'authorizationStateWaitPhoneNumber' then
        client:send('setAuthenticationPhoneNumber', {
            phone_number = prompt('Telegram phone number (international format): '),
        })
    elseif kind == 'authorizationStateWaitCode' then
        client:send('checkAuthenticationCode', {
            code = prompt('Login code from Telegram: '),
        })
    elseif kind == 'authorizationStateWaitPassword' then
        client:send('checkAuthenticationPassword', {
            password = prompt('Telegram two-step verification password: '),
        })
    elseif kind == 'authorizationStateWaitEmailAddress' then
        client:send('setAuthenticationEmailAddress', {
            email_address = prompt('Telegram login email: '),
        })
    elseif kind == 'authorizationStateWaitEmailCode' then
        client:send('checkAuthenticationEmailCode', {
            code = {
                ['@type'] = 'emailAddressAuthenticationCode',
                code = prompt('Telegram email code: '),
            },
        })
    end
end

user.on_authorized = function()
    print('User account is signed in; session is stored in the private TDLib database.')
end

user.on_update = function(update)
    if update['@type'] == 'error' then
        io.stderr:write('TDLib error ', tostring(update.code), ': ', tostring(update.message), '\n')
    end
end

user:run() -- keep this process running to receive updates
```

Start it with:

```bash
luajit ./userbot.lua
```

On first run, type your own phone number, then the login code Telegram sends (it may arrive in an existing Telegram session). If two-step verification or email verification is enabled, type the requested password, email address, or email code when prompted. Once authorized, TDLib saves the encrypted login session in the database directory; later runs use that session. Keep the database directory and encryption key private and backed up together. The `export` commands above apply to the current shell; for a service or later session, configure the same variables in a protected environment file. Stop the running client with `Ctrl+C`.

After sign-in, use named methods such as `user:send_message(chat_id, 'Hello')` or `user:upload_story(...)`; their requests are asynchronous and responses arrive through `user.on_update`. TDLib calls that do not yet have a named wrapper are available through `user:send('methodName', params)`. See [the full UserBot guide](docs/userbot.md) for all wrappers and examples. Never share login codes, passwords, API hashes, or the session database.

> **Note:** Automated activity on a personal Telegram account can lead to limits or bans if it looks like spam. Test with a secondary account first.

## Quick Start

```lua
local api = require('titogramlua').configure('YOUR_BOT_TOKEN')

function api.on_message(message)
    if message.text then
        api.send_message(message.chat.id, 'You said: ' .. message.text)
    end
end

api.run({ timeout = 60 })
```

`api.run()` is async by default: each update gets its own coroutine and all API calls are non-blocking.

## Key Features

- Full Bot API 10.3 coverage (messages, media, payments, stickers, forums, games, gifts, stories, business accounts, rich messages, live photos, and more)
- **Async-first architecture** via copas: concurrent updates, parallel API calls, background tasks
- **Framework layer**: command router, conversations, and per-chat/user sessions
- **Built-in webhook receiver** with x-telegram-bot-api secret-token verification
- **Automatic 429 / retry_after flood-control** with bounded exponential backoff
- **Structured logging and lightweight metrics** with a configurable sink
- **Built-in adapters**: SQLite, PostgreSQL, Redis, OpenAI, Anthropic (Claude), and SMTP email
- **Lua 5.1 - 5.5 support** with automatic polyfills for bitwise operations and string.pack
- Clean opts-table pattern for all API methods
- Chainable keyboard and inline result builders
- Text formatting helpers for HTML, Markdown, and MarkdownV2
- Command parsing, pagination, deep links, and callback data encoding
- Member status helpers and chat permission checks
- Legacy v2 compatibility layer with deprecation warnings
- Optional Telegram user-account client powered by TDLib (LuaJIT + native TDLib required)

## Documentation

| Document | Description |
|---|---|
| [Getting Started](docs/getting-started.md) | Installation, configuration, and first bot |
| [Update Handlers](docs/handlers.md) | All available update handler functions |
| [API Methods](docs/methods.md) | Complete method reference |
| [Builders](docs/builders.md) | Keyboards, inline results, and type constructors |
| [Framework](docs/framework.md) | Command router, sessions, conversations, webhooks, retries, logging |
| [Utilities](docs/utilities.md) | Formatting, command parsing, pagination, and tools |
| [Async / Concurrency](docs/async.md) | Concurrent updates, parallel calls, background tasks |
| [Adapters](docs/adapters.md) | Database, Redis, LLM, and email integrations |
| [Migration from v2](docs/migration.md) | Breaking changes and upgrade guide |
| [User accounts / MTProto](docs/userbot.md) | Optional LuaJIT + TDLib user-account client |

## Example

```lua
local api = require('titogramlua').configure(os.getenv('BOT_TOKEN'))

-- Connect adapters
local db = api.db.connect({ driver = 'sqlite', path = 'bot.db' })
db:execute('CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)')

local llm = api.llm.new({
    provider = 'anthropic',
    api_key = os.getenv('ANTHROPIC_API_KEY'),
    model = 'claude-sonnet-4-6',
})

function api.on_message(message)
    if not message.text then return end
    local cmd = api.extract_command(message)

    if cmd and cmd.command == 'start' then
        local name = api.fmt.bold(api.get_name(message.from))
        db:execute('INSERT OR IGNORE INTO users VALUES (?, ?)', {message.from.id, message.from.first_name})
        api.send_message(message.chat.id, 'Welcome, ' .. name .. '!', {
            parse_mode = 'HTML',
            reply_markup = api.inline_keyboard()
                :row(api.row()
                    :callback_data_button('Help', 'help')
                    :callback_data_button('Ask AI', 'ai'))
        })
    elseif cmd and cmd.command == 'ask' and cmd.args_str then
        api.send_typing(message.chat.id)
        local result = llm:chat({{ role = 'user', content = cmd.args_str }})
        api.send_message(message.chat.id, result and result.content or 'Sorry, error occurred.')
    end
end

api.run({ timeout = 60 })
```

## Module Structure

```
src/
  main.lua              -- Entry point, core HTTP, module loader
  config.lua            -- API endpoint configuration
  polyfill.lua          -- Lua 5.1+ compatibility (bit ops, string.pack)
  async.lua             -- Copas-based concurrency module
  b64url.lua            -- Base64 URL encoding/decoding
  log.lua               -- Structured logging and lightweight metrics
  tools.lua             -- Utility functions (formatting, file ops, etc.)
  handlers.lua          -- Update routing and on_* handler stubs (async-first)
  builders.lua          -- Keyboard, inline result, and type constructors
  builders_rich.lua     -- Rich message builders (RichText/RichBlock DSL)
  helpers.lua           -- Member status check helpers
  session.lua           -- Per-chat/user session store (pluggable backends)
  framework.lua         -- Command router, rich ctx, and conversations
  webhook.lua           -- Webhook receiver (process + turnkey copas server)
  utils.lua             -- Bot development utilities (fmt, commands, pagination)
  compat.lua            -- v2 backward compatibility layer
  adapters/
    init.lua            -- Adapter registry and shared utilities
    db.lua              -- Database adapter (SQLite, PostgreSQL)
    redis.lua           -- Redis adapter (RESP protocol)
    llm.lua             -- LLM adapter (OpenAI, Anthropic)
    email.lua           -- Email adapter (SMTP)
  methods/
    messages.lua        -- send_*, forward_*, copy_*, edit_*, delete_*
    updates.lua         -- get_updates, webhooks
    chat.lua            -- Chat management
    members.lua         -- Member management (ban, restrict, promote)
    forum.lua           -- Forum topic management
    stickers.lua        -- Sticker operations
    inline.lua          -- Inline queries and callback queries
    payments.lua        -- Invoices, payments, stars
    games.lua           -- Game methods
    passport.lua        -- Passport data errors
    bot.lua             -- Bot profile and settings
    gifts.lua           -- Gift methods
    checklists.lua      -- Checklist methods
    stories.lua         -- Story methods
    business.lua        -- Business account methods
    suggested_posts.lua -- Suggested post methods
    rich.lua            -- Rich message methods (send_rich_message, drafts)
    userbot.lua         -- Optional TDLib-backed user-account client entry point
    userbot/
      send_message.lua  -- Send a text message
      send_photo.lua    -- Send a photo
      edit_message_text.lua
      delete_messages.lua
      get_chat.lua
      get_chats.lua
      get_message.lua
      get_messages.lua
      search_messages.lua
      upload_story.lua  -- Post a photo or video story
      get_story.lua
      get_chat_active_stories.lua
      delete_story.lua
      edit_story.lua
      set_story_privacy_settings.lua
      send.lua          -- Low-level TDLib request
      execute.lua       -- Synchronous TDLib method
      receive.lua       -- Receive and dispatch one TDLib update
      run.lua           -- Run the receive loop
      stop.lua          -- Stop the receive loop
      close.lua         -- Close the TDLib client
```

## Testing

```
luarocks install busted
busted
```

## Migrating from v2

v3 includes a compatibility layer that lets most v2 code run with deprecation warnings. Here's what to do:

### 1. Update

```
luarocks install titogramlua
```

LuaRocks handles dependency changes automatically (`lpeg` and `html-entities` removed, `copas` added).

### 2. Update your require (optional but recommended)

```lua
-- v2
local api = require('titogramlua.core').configure('TOKEN')

-- v3
local api = require('titogramlua').configure('TOKEN')
```

The old `require('titogramlua.core')` still works but prints a deprecation warning.

### 3. Update method calls (optional but recommended)

v3 uses options tables instead of positional args. The compat layer auto-detects v2-style calls and converts them, but you should update your code:

```lua
-- v2
api.send_message(chat_id, text, nil, 'HTML', nil, nil, false, false, reply_params, reply_markup)
api.send_photo(chat_id, photo, nil, 'Caption', 'HTML')
api.answer_callback_query(id, 'Alert text', true)
api.edit_message_text(chat_id, msg_id, text, 'HTML')
api.run(1, 60)

-- v3
api.send_message(chat_id, text, { parse_mode = 'HTML', reply_parameters = reply_params, reply_markup = reply_markup })
api.send_photo(chat_id, photo, { caption = 'Caption', parse_mode = 'HTML' })
api.answer_callback_query(id, { text = 'Alert text', show_alert = true })
api.edit_message_text(chat_id, msg_id, text, { parse_mode = 'HTML' })
api.run({ timeout = 60 })
```

### 4. Renamed methods

These v2 methods are aliased with deprecation warnings:

| v2 | v3 |
|----|-----|
| `kick_chat_member(chat_id, user_id, until_date)` | `ban_chat_member(chat_id, user_id, opts)` |
| `get_chat_members_count(chat_id)` | `get_chat_member_count(chat_id)` |

### 5. Async is now the default

`api.run()` uses copas for concurrent update processing. Each handler runs in its own coroutine. For the old sequential behaviour:

```lua
api.run({ sync = true, timeout = 60 })
```

### What doesn't need migration

- Handler functions (`api.on_message`, `api.on_callback_query`, etc.) — same pattern
- Builder methods (`api.keyboard()`, `api.inline_keyboard()`, etc.) — same API
- Tool functions (`tools.escape_html`, `tools.comma_value`, etc.) — same API
- No config files, secrets, or environment variables to migrate

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.

Copyright (c) 2017-2026 Yousef Hesham

Portions Copyright (c) Matthew Hesketh, from the original [telegram-bot-lua](https://github.com/wrxck/telegram-bot-lua) project. Keep the original copyright notices in the `LICENSE` file, as the GPL requires.

### User account method adapters

The optional LuaJIT/TDLib user client includes Ravengram-inspired methods, stories, event registration and composed operations. Read [userbot setup](docs/userbot.md) and [the complete adapter catalog and limitations](docs/userbot-port.md). TDLib sessions are database-backed; portable Pyrogram session strings are not supported.
