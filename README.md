# telegram-bot-lua

[![audited by auto-audit](https://img.shields.io/badge/audited_by-auto--audit-6366f1?logo=github&logoColor=white)](https://auto-audit.hesketh.pro)

A feature-filled Telegram bot API library written in Lua, created by [Matt](https://t.me/wrxck). Supports Bot API 10.1 with full coverage of all available methods.

## Installation

Requires Lua 5.1+ and LuaRocks:

```
luarocks install telegram-bot-lua
```

## Quick Start

```lua
local api = require('telegram-bot-lua').configure('YOUR_BOT_TOKEN')

function api.on_message(message)
    if message.text then
        api.send_message(message.chat.id, 'You said: ' .. message.text)
    end
end

api.run({ timeout = 60 })
```

`api.run()` is async by default: each update gets its own coroutine and all API calls are non-blocking.

## Key Features

- Full Bot API 10.1 coverage (messages, media, payments, stickers, forums, games, gifts, stories, business accounts, rich messages, live photos, and more)
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

## Example

```lua
local api = require('telegram-bot-lua').configure(os.getenv('BOT_TOKEN'))

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
luarocks install telegram-bot-lua
```

LuaRocks handles dependency changes automatically (`lpeg` and `html-entities` removed, `copas` added).

### 2. Update your require (optional but recommended)

```lua
-- v2
local api = require('telegram-bot-lua.core').configure('TOKEN')

-- v3
local api = require('telegram-bot-lua').configure('TOKEN')
```

The old `require('telegram-bot-lua.core')` still works but prints a deprecation warning.

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

Copyright (c) 2017-2026 Matthew Hesketh
