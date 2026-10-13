# Wallet Pay

TitogramLua's Bot API methods handle Telegram invoices and Telegram Stars. Wallet Pay is a separate merchant service, so it uses a separate client and a store API key from [pay.wallet.tg](https://pay.wallet.tg/).

## Setup

Create and verify a Wallet Pay merchant account, create a store, then generate that store's API key. Keep the key in a server-side environment variable:

```sh
export WALLET_PAY_API_KEY='your-store-api-key'
```

Never put the key in a bot message, browser code, repository, or logs.

## Create a payment order

```lua
local WalletPay = require('titogramlua.wallet_pay')
local wallet = WalletPay.new({
    api_key = assert(os.getenv('WALLET_PAY_API_KEY'), 'set WALLET_PAY_API_KEY'),
})

local order, err = wallet:create_order({
    amount = { currencyCode = 'TON', amount = '10.67' },
    description = 'Premium access',
    externalId = 'order-123',
    returnUrl = 'https://t.me/your_bot',
    failReturnUrl = 'https://t.me/your_bot',
    customerTelegramUserId = 123456789,
})

if not order then
    error(err.message)
end

-- Send the returned payLink to the user from your bot.
local pay_link = order.data.payLink
api.send_message(123456789, 'Complete your payment: ' .. pay_link)
```

The amount and currency must follow Wallet Pay's current merchant API rules. The API key is not the Telegram BotFather token.

## Check an order and reconcile

```lua
local preview, preview_err = wallet:get_order_preview(order.data.id)
local page, page_err = wallet:get_order_list({ offset = 0, count = 20 })
local totals, totals_err = wallet:get_order_amount()
```

Each method returns the decoded Wallet Pay response and, on failure, an error table. Reconciliation calls support `offset` and `count`.

## Verify payment webhooks

Configure the webhook URL in the Wallet Pay store settings. Verify the signature against the exact raw HTTP request body before fulfilling an order:

```lua
local valid = wallet:verify_webhook(
    'POST',
    '/your/wallet-pay/webhook',
    request.headers['WalletPay-Timestamp'],
    request.headers['WalletPay-Signature'],
    request.raw_body
)
if not valid then
    return 401
end

-- Process only ORDER_PAID events. Persist eventId/order ID so retries
-- cannot fulfill the same purchase more than once.
```

Webhook verification uses HMAC-SHA-256. It requires the optional `luaossl` dependency; install it with `luarocks install luaossl`. Preserve the raw body exactly as received. Use the exact route path configured in Wallet Pay.

Wallet Pay sends payment events asynchronously. Do not grant a purchase just because the browser returned to `returnUrl`; verify the signed webhook or query the order status server-side. See the [Wallet Pay API documentation](https://docs.wallet.tg/pay/).

