-- Optional client for the RavenGram raw MTProto wallet bridge.
-- See examples/mtproto-wallet/README.md for setup and security requirements.
local json = require('dkjson')
local http = require('socket.http')
local ltn12 = require('ltn12')

local Wallet = {}
Wallet.__index = Wallet

local methods = {
    get_state = 'wallet.getState',
    get_user_addresses = 'wallet.getUserAddresses',
    get_transactions = 'wallet.getTransactions',
    get_transactions_by_ids = 'wallet.getTransactionsByIDs',
    get_transactions_by_msg_hash = 'wallet.getTransactionsByMsgHash',
    export_secret_phrase = 'wallet.exportSecretPhrase',
    fetch_encrypted_secret_phrase_part = 'wallet.fetchEncryptedSecretPhrasePart',
    replace_wallet = 'wallet.replaceWallet',
    disable_backup = 'wallet.disableBackup',
    get_backup_holder_dcs = 'wallet.getBackupHolderDcs',
    enable_backup = 'wallet.enableBackup',
    get_proof_challenge = 'wallet.getProofChallenge',
    send_transfer = 'wallet.sendTransfer',
    get_gasless_info = 'wallet.getGaslessInfo',
    get_existing_wallet_balance = 'wallet.getExistingWaltBalance',
    get_nfts = 'wallet.getNfts',
    ton_connect_create_session = 'wallet.tonConnectCreateSession',
    ton_connect_register_key = 'wallet.tonConnectRegisterKey',
    ton_connect_submit_connect_result = 'wallet.tonConnectSubmitConnectResult',
    ton_connect_get_pending = 'wallet.tonConnectGetPending',
    ton_connect_claim_request = 'wallet.tonConnectClaimRequest',
    ton_connect_submit_response = 'wallet.tonConnectSubmitResponse',
    ton_connect_next_event_id = 'wallet.tonConnectNextEventId',
    ton_connect_close_session = 'wallet.tonConnectCloseSession',
    ton_connect_get_sessions = 'wallet.tonConnectGetSessions',
}

function Wallet.new(options)
    options = options or {}
    assert(type(options) == 'table', 'options must be a table')
    local url = options.url or 'http://127.0.0.1:8765/rpc'
    assert(type(url) == 'string' and
        (url:match('^http://127%.0%.0%.1:%d+/rpc$') or url:match('^http://localhost:%d+/rpc$')),
        'wallet bridge URL must use local loopback HTTP')
    assert(type(options.token) == 'string' and #options.token >= 32,
        'a bridge token of at least 32 characters is required')
    return setmetatable({url = url, token = options.token}, Wallet)
end

function Wallet:call(method, params)
    assert(type(method) == 'string' and method:match('^wallet%.[%w]+$'),
        'method must be a wallet.* MTProto function')
    assert(params == nil or type(params) == 'table', 'params must be a table')
    local body = assert(json.encode({method = method, params = params or {}}))
    local chunks = {}
    local _, status = http.request({
        url = self.url,
        method = 'POST',
        headers = {
            ['Content-Type'] = 'application/json',
            ['Content-Length'] = tostring(#body),
            ['Authorization'] = 'Bearer ' .. self.token,
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(chunks),
    })
    local payload = table.concat(chunks)
    local response, _, decode_error = json.decode(payload)
    if tonumber(status) ~= 200 then
        local message = type(response) == 'table' and response.error or payload
        return nil, {code = tonumber(status) or 0, message = tostring(message)}
    end
    if type(response) ~= 'table' then
        return nil, {code = 0, message = 'invalid bridge response: ' .. tostring(decode_error)}
    end
    if response.error then
        return nil, {code = tonumber(response.code) or 0, message = tostring(response.error)}
    end
    return response.result
end

for name, method in pairs(methods) do
    Wallet[name] = function(self, params)
        return self:call(method, params)
    end
end

Wallet.methods = methods
return Wallet
