# Native MTProto Layer 225

This optional module adds a Layer 225 TL request encoder for the native Lua MTProto client. It does not change the Bot API client or the separate TDLib UserBot. The method IDs and fields follow Telegram's [Layer 225 changelog](https://core.telegram.org/api/layers) and [TL schema](https://core.telegram.org/schema).

## Covered calls

The module encodes all 13 methods introduced in Layer 225:

- `messages.setBotGuestChatResult`
- `messages.deleteParticipantReactions` and `messages.deleteParticipantReaction`
- `messages.getPersonalChannelHistory`
- `bots.getAccessSettings` and `bots.editAccessSettings`
- `stats.getPollStats`
- `aicompose.createTone`, `updateTone`, `saveTone`, `deleteTone`, `getTone`, `getTones`, and `getToneExample`

It also encodes the Layer 225 changes to `contacts.getTopPeers` (including `bots_guestchat`) and `messages.composeMessageWithAI` (including `tone`). Optional TL flags and the `Bool` parameters on tone methods are encoded according to the schema.

## Use

Create and authorize the native Lua MTProto `Client` as described in [the experimental MTProto wallet guide](../examples/mtproto-wallet/readme.md). Set `layer = 225` when constructing it, then pass the authorized client to this module:

```lua
local Client = require('titogramlua.mtproto.client')
local Layer225 = require('titogramlua.mtproto.layer225')

local client = Client.new({
    api_id = assert(tonumber(os.getenv('TELEGRAM_API_ID'))),
    api_hash = assert(os.getenv('TELEGRAM_API_HASH')),
    layer = 225,
    dc_id = 2,
    host = '149.154.167.40',
    port = 443,
})

-- connect and complete phone-code / optional 2FA authorization here
local api = Layer225.new(client)
local peer = Layer225.objects.input_peer_channel(channel_id, channel_access_hash)
local result, err = api:call('messages.deleteParticipantReactions', {
    peer = peer,
    participant = Layer225.objects.input_peer_user(user_id, user_access_hash),
})
if not result then error(type(err) == 'table' and err.message or err) end
```

Nested TL parameters are built with `Layer225.objects` helpers (currently `input_user`, `input_user_self`, `input_peer_user`, `input_peer_chat`, `input_peer_channel`, `input_peer_self`, and the three `input_ai_compose_tone_*` constructors). For a constructor not covered by a helper, pass a trusted, schema-compatible encoded object as `{ _tl = encoded_bytes }`. `messages.setBotGuestChatResult` accepts an `InputBotInlineResult` in this form.

Example for managing custom compose tones:

```lua
local tone_ref = Layer225.objects.input_ai_compose_tone_slug('friendly')
local tones, err = api:call('aicompose.getTone', {tone = tone_ref})
if not tones then error(err.message or err) end
-- Preserve tones.raw when the generated result object is not decoded.
```

## Response and scope

The native client returns the exact TL response in `result.raw` and its constructor ID in `result.constructor`. Generated response objects such as `messages.Messages`, `stats.PollStats`, `aicompose.tones`, and `bots.AccessSettings` are not yet decoded into complete Lua tables; inspect or preserve the raw bytes. This is request coverage and raw-response access, not a complete generated MTProto schema or general update dispatcher. The current client also has a wallet-oriented decoder, so `result.data` may be absent for these types.

The methods require an account-authorized user MTProto session. Availability and access checks are enforced by Telegram; for example managed bot access settings are manager-bot-only. This module does not bypass those restrictions.
