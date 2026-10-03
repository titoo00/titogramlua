# Framework

The framework layer adds a command router, conversations, sessions, a webhook
receiver, flood-control retries, and structured logging/metrics. It is fully
additive and opt-in: if you register no command, hears, or conversation, dispatch
is unchanged and your existing `on_*` handlers run as before.

## Command Router

Register handlers by command name. Handlers receive a [context](#context), not a
raw message.

```lua
local api = require('telegram-bot-lua').configure(os.getenv('BOT_TOKEN'))

api.command('start', function(ctx)
    ctx.reply('Welcome!')
end)

-- guarded command: the handler only runs if guard(ctx) returns truthy
api.command('ban', {
    guard = function(ctx) return api.is_user_group_admin(ctx.chat_id, ctx.from.id) end,
    on_denied = function(ctx) ctx.reply('Admins only.') end
}, function(ctx)
    -- ctx.args is the parsed argument list, ctx.args_str the raw remainder
    ctx.reply('Banning ' .. (ctx.args[1] or '?'))
end)

-- match free text with a lua pattern or a function(text)
api.hears('^hello', function(ctx) ctx.reply('Hi there!') end)
api.hears(function(text) return text:find('bye') end, function(ctx) ctx.reply('Bye!') end)

-- fallback for a /command with no registered handler
api.on_command_not_found(function(ctx)
    ctx.reply('Unknown command: ' .. ctx.command)
end)

api.run({ timeout = 60 })
```

Dispatch order per update is: pending conversation, then commands, then hears.
The first match consumes the update; otherwise the `on_*` handlers run.

## Context

`api.build_context(update)` turns a raw update into a `ctx`. The router builds it
for you, but you can call it directly when handling updates yourself.

Fields:

| Field | Description |
|---|---|
| `ctx.update` | the raw update |
| `ctx.update_type` | e.g. `'message'`, `'callback_query'`, `'inline_query'` |
| `ctx.payload` | the update payload for that type |
| `ctx.message` | the message (for message-like updates, or a callback's message) |
| `ctx.chat` / `ctx.chat_id` | the chat and its id |
| `ctx.from` | the sender (`User`) |
| `ctx.session` | the [session](#sessions) table for this chat/user (if sessions are loaded) |

Inside command/hears handlers, `ctx.command`, `ctx.args`, `ctx.args_str`, and
`ctx.match` are also set.

Methods:

```lua
ctx.reply(text, opts)              -- send_message to ctx.chat_id
ctx.reply_with_photo(photo, opts)  -- send_photo to ctx.chat_id
ctx.answer(opts)                   -- answer_callback_query (callback updates only)
```

```lua
local ctx = api.build_context(update)
if ctx.update_type == 'callback_query' then
    ctx.answer({ text = 'Got it' })
end
```

## Sessions

A per-chat/user store keyed by `chat_id:user_id`. The default backend is
in-memory; swap it for a Redis- or DB-backed one.

```lua
-- the session for an update (also exposed as ctx.session)
local s = api.session.get(update)
s.count = (s.count or 0) + 1

api.session.set(update, { count = 0 })   -- replace the whole value
api.session.clear(update)                -- drop it
```

Backends are tables with `get(self, key)`, `set(self, key, value)`, and
`clear(self, key)`. `api.session.memory()` builds the default in-memory backend;
`api.session.use(backend)` installs a replacement.

```lua
api.session.use(api.session.memory())   -- the default

-- a custom backend (e.g. backed by the redis adapter)
api.session.use({
    get   = function(_, key) return load_from_redis(key) or {} end,
    set   = function(_, key, value) save_to_redis(key, value) end,
    clear = function(_, key) delete_from_redis(key) end
})
```

## Conversations

A conversation is a `function(ctx)` that can call `ctx.wait_for()` to suspend
until the user's next message or callback arrives. It works in both sync and
async (`api.run()`) modes.

```lua
api.conversation('signup', function(ctx)
    ctx.reply('What is your name?')
    local name = ctx.wait_for().message.text

    ctx.reply('And your age?')
    local age = ctx.wait_for().message.text

    ctx.session.name = name
    ctx.session.age = age
    ctx.reply('Thanks, ' .. name .. '!')
end)

api.command('signup', function(ctx)
    api.enter('signup', ctx.update)   -- start the wizard for this user
end)

api.run({ timeout = 60 })
```

`api.enter(fn_or_name, update)` starts a conversation: pass either a registered
name or a `function(ctx)` directly. Each `ctx.wait_for()` returns the `ctx` of the
next update from the same chat/user.

## Webhook Receiver

Two entry points; both verify the `x-telegram-bot-api-secret-token` when a secret
is configured.

### Bring your own server

`api.webhook.process(body, opts)` verifies the secret and dispatches an update you
already received over your own HTTP stack. `body` may be a raw JSON string or a
decoded table.

```lua
-- inside your HTTP handler
local ok, reason = api.webhook.process(request_body, {
    secret_token    = os.getenv('WEBHOOK_SECRET'),         -- the secret set with setWebhook
    received_secret = headers['x-telegram-bot-api-secret-token']
})
-- ok is false + reason on a bad secret or invalid payload
```

### Turnkey server

`api.webhook.serve(opts)` runs a minimal copas HTTP server that accepts Telegram
webhooks.

```lua
api.webhook.serve({
    host = '0.0.0.0',
    port = 8443,
    path = '/bot',                       -- optional path prefix to require
    secret_token = os.getenv('WEBHOOK_SECRET')
})
```

It only accepts `POST`, returns `200 OK` on success, and never lets a handler
error take down the server. Pass `{ no_loop = true }` to register the server
without entering `copas.loop()` (when you run your own loop).

## Retries / Flood Control

Every request runs under a retry policy. Telegram's `429` `retry_after` is honoured
automatically, and transient connection failures back off with bounded exponential
delay; a normal 4xx API error is returned immediately (not retried).

```lua
api.retry = {
    enabled = true,
    max_attempts = 3,
    base_delay = 1,    -- seconds
    max_delay = 30     -- cap for exponential backoff
}

api.retry.enabled = false   -- opt out entirely
```

## Logging & Metrics

Structured logging through a configurable sink with level filtering, plus simple
named counters.

```lua
api.log.level = 'debug'   -- 'debug' | 'info' | 'warn' | 'error' (default 'info')

api.log.debug('verbose detail')
api.log.info('update processed')
api.log.warn('slow response')
api.log.error('request failed', err)

-- route logs elsewhere (default prints "[level] message")
function api.log.sink(level, message)
    write_to_file(level, message)
end
```

```lua
api.metrics.incr('updates')        -- +1
api.metrics.incr('requests', 5)    -- +5
api.metrics.get('updates')         -- read one counter (0 if unset)
api.metrics.all()                  -- a shallow copy of all counters
api.metrics.reset()                -- zero everything
```
