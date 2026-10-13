--- Wallet Pay client for accepting Wallet payments from a Telegram bot.
-- This is a merchant API client and is separate from the Telegram Bot API.
local json = require('dkjson')
local https = require('ssl.https')
local ltn12 = require('ltn12')
local url = require('socket.url')

local WalletPay = {}
WalletPay.__index = WalletPay

local DEFAULT_BASE_URL = 'https://pay.wallet.tg'
local ORDER_PATH = '/wpay/store-api/v1/order'
local PREVIEW_PATH = '/wpay/store-api/v1/order/preview'
local ORDER_LIST_PATH = '/wpay/store-api/v1/reconciliation/order-list'
local ORDER_AMOUNT_PATH = '/wpay/store-api/v1/reconciliation/order-amount'

local function encode_query(params)
    local parts = {}
    for key, value in pairs(params or {}) do
        if value ~= nil then
            parts[#parts + 1] = url.escape(tostring(key)) .. '=' .. url.escape(tostring(value))
        end
    end
    table.sort(parts)
    return #parts > 0 and ('?' .. table.concat(parts, '&')) or ''
end

local function json_response(body)
    local value, _, err = json.decode(body or '')
    if err then
        return nil, { message = 'Wallet Pay returned invalid JSON', detail = err, body = body }
    end
    return value
end

--- Create a Wallet Pay client.
-- Keep the store API key on the server; never expose it to a browser or commit it.
-- @param opts table with api_key, optional base_url and default timeout_seconds
-- @return table Wallet Pay client
function WalletPay.new(opts)
    opts = opts or {}
    assert(type(opts.api_key) == 'string' and opts.api_key ~= '', 'Wallet Pay api_key is required')
    local base_url = opts.base_url or DEFAULT_BASE_URL
    assert(type(base_url) == 'string' and base_url:match('^https://'), 'Wallet Pay base_url must use HTTPS')
    return setmetatable({
        api_key = opts.api_key,
        base_url = base_url:gsub('/+$', ''),
        timeout_seconds = opts.timeout_seconds or 10800
    }, WalletPay)
end

--- Make a Wallet Pay HTTPS request.
-- @param method string HTTP method
-- @param path string Wallet Pay API path
-- @param params table query parameters for GET or JSON body for POST
-- @return table|nil decoded response
-- @return table|nil error details when the request fails
function WalletPay:request(method, path, params)
    assert(method == 'GET' or method == 'POST', 'method must be GET or POST')
    assert(type(path) == 'string' and path:sub(1, 1) == '/', 'path must start with /')
    params = params or {}
    local body = ''
    local request_url = self.base_url .. path
    if method == 'GET' then
        request_url = request_url .. encode_query(params)
    else
        body = json.encode(params)
    end

    local response = {}
    local headers = {
        ['Accept'] = 'application/json',
        ['Wpay-Store-Api-Key'] = self.api_key
    }
    if method == 'POST' then
        headers['Content-Type'] = 'application/json'
        headers['Content-Length'] = tostring(#body)
    end

    local ok, code, response_headers, status = https.request({
        url = request_url,
        method = method,
        headers = headers,
        source = method == 'POST' and ltn12.source.string(body) or nil,
        sink = ltn12.sink.table(response)
    })
    local response_body = table.concat(response)
    if not ok then
        return nil, { message = tostring(code or 'Wallet Pay request failed'), status = status }
    end
    local decoded, decode_err = json_response(response_body)
    if not decoded then
        return nil, { message = decode_err.message, detail = decode_err.detail, status = code, body = response_body }
    end
    if tonumber(code) < 200 or tonumber(code) >= 300 then
        return nil, { message = decoded.message or decoded.description or 'Wallet Pay API error',
            status = tonumber(code), response = decoded, headers = response_headers }
    end
    return decoded, nil, tonumber(code), response_headers
end

--- Create a Wallet Pay order and return its payment link.
-- @param order table Wallet Pay create-order fields (amount, description, returnUrl, etc.)
-- @return table|nil API response
-- @return table|nil error details
function WalletPay:create_order(order)
    assert(type(order) == 'table', 'order must be a table')
    local payload = {}
    for key, value in pairs(order) do payload[key] = value end
    if payload.timeoutSeconds == nil then payload.timeoutSeconds = self.timeout_seconds end
    return self:request('POST', ORDER_PATH, payload)
end

--- Fetch an order preview/status by its Wallet Pay order ID.
-- @param order_id string|number Wallet Pay order ID
-- @return table|nil API response
-- @return table|nil error details
function WalletPay:get_order_preview(order_id)
    assert(order_id ~= nil, 'order_id is required')
    return self:request('GET', PREVIEW_PATH, { id = order_id })
end

--- Fetch a page of Wallet Pay orders.
-- @param opts table optional offset and count (defaults to 0 and 10)
-- @return table|nil API response
-- @return table|nil error details
function WalletPay:get_order_list(opts)
    opts = opts or {}
    return self:request('GET', ORDER_LIST_PATH, {
        offset = opts.offset or 0,
        count = opts.count or 10
    })
end

--- Fetch the aggregate amount of Wallet Pay orders.
-- @param opts table optional offset and count when supported by the API
-- @return table|nil API response
-- @return table|nil error details
function WalletPay:get_order_amount(opts)
    return self:request('GET', ORDER_AMOUNT_PATH, opts or {})
end

local function standard_base64(binary)
    local encoded = require('titogramlua.b64url').encode(binary)
    encoded = encoded:gsub('-', '+'):gsub('_', '/')
    return encoded .. string.rep('=', (4 - (#encoded % 4)) % 4)
end

local function constant_time_equal(a, b)
    if type(a) ~= 'string' or type(b) ~= 'string' or #a ~= #b then return false end
    local diff = 0
    for i = 1, #a do
        if a:byte(i) ~= b:byte(i) then diff = diff + 1 end
    end
    return diff == 0
end

--- Verify the Wallet Pay webhook signature using the raw request body.
-- The caller must also check event IDs to avoid processing duplicate deliveries.
-- @param method string incoming HTTP method, usually POST
-- @param uri_path string exact path configured in Wallet Pay, including any query string if present
-- @param timestamp string WalletPay-Timestamp header
-- @param signature string WalletPay-Signature header
-- @param raw_body string exact unmodified HTTP request body
-- @return boolean true only when the HMAC-SHA-256 signature matches
function WalletPay:verify_webhook(method, uri_path, timestamp, signature, raw_body)
    if type(method) ~= 'string' or type(uri_path) ~= 'string'
        or type(timestamp) ~= 'string' or type(signature) ~= 'string'
        or type(raw_body) ~= 'string' then
        return false
    end
    local hmac = require('openssl.hmac')
    local signer = hmac.new(self.api_key, 'sha256')
    local signed_body = method .. '.' .. uri_path .. '.' .. timestamp .. '.' .. standard_base64(raw_body)
    signer:update(signed_body)
    return constant_time_equal(standard_base64(signer:final()), signature)
end

return WalletPay
