-- Native Lua MTProto session client.
-- Auth-key creation is separate from account authorization; wallet methods
-- require a user-authorized session and a Telegram layer capable of wallet.*.
local Transport = require('titogramlua.mtproto.transport')
local auth = require('titogramlua.mtproto.auth')
local tl = require('titogramlua.mtproto.tl')
local crypto = require('titogramlua.mtproto.crypto')
local message = require('titogramlua.mtproto.message')
local wallet = require('titogramlua.mtproto.wallet_encode')
local wallet_decode = require('titogramlua.mtproto.wallet_decode')
local srp = require('titogramlua.mtproto.srp')
local SessionStore = require('titogramlua.mtproto.session_store')

local Client = {}
Client.__index = Client

local INVOKE_WITH_LAYER = 0xda9b0d0d
local INIT_CONNECTION = 0xc1cd5ea9
local RPC_RESULT = 0xf35c6d01
local RPC_ERROR = 0x2144ca19
local MSG_CONTAINER = 0x73f1f8dc
local PONG = 0x347773c5
local NEW_SESSION_CREATED = 0x9ec20908
local BAD_SERVER_SALT = 0xedab447b
local AUTH_SENT_CODE = 0x5e002502
local AUTH_SENT_CODE_SUCCESS = 0x2390fe44
local AUTHORIZATION = 0x2ea2c0d4
local AUTH_SIGNUP_REQUIRED = 0x44747e9a
local ACCOUNT_PASSWORD = 0x957b50fb
local PASSWORD_KDF = 0x3a912d4a
local SESSION_PASSWORD_NEEDED = 'SESSION_PASSWORD_NEEDED'

function Client.new(options)
    options = options or {}
    assert(type(options.api_id) == 'number' and options.api_id > 0,
        'Telegram api_id is required')
    assert(type(options.api_hash) == 'string' and options.api_hash ~= '',
        'Telegram api_hash is required')
    local session = options.session or {}
    return setmetatable({
        transport = Transport.new(options),
        options = options,
        state = 'disconnected',
        auth_key = session.auth_key or options.auth_key,
        auth_key_id = session.auth_key and crypto.sha1(session.auth_key):sub(13, 20) or options.auth_key_id,
        server_salt = session.server_salt or options.server_salt,
        session_id = session.session_id or options.session_id,
        authorized = session.authorized == true,
        time_offset = session.server_time_offset or options.server_time_offset or 0,
        last_message_seconds = 0,
        message_counter = 0,
        sequence = 0,
        pending = {},
        initialized = session.initialized == true,
    }, Client)
end

function Client:_message_id()
    local seconds = os.time() + self.time_offset
    if seconds < self.last_message_seconds then seconds = self.last_message_seconds end
    if seconds > self.last_message_seconds then
        self.last_message_seconds, self.message_counter = seconds, 0
    else
        self.message_counter = self.message_counter + 1
    end
    -- low 32 bits are a 1/2^32-second fraction, rounded to a multiple of four.
    local fraction = (self.message_counter * 4) % 0x100000000
    return tl.uint(fraction) .. tl.uint(seconds)
end

function Client:_encrypted_rpc(query, timeout)
    assert(self.auth_key and #self.auth_key == 256, 'MTProto auth key is not initialized')
    local raw_id = self:_message_id()
    local seq_no = self.sequence * 2 + 1
    self.sequence = self.sequence + 1
    local body = message.pack(self.auth_key, self.session_id, self.server_salt,
        raw_id, seq_no, query)
    local ok, err = self.transport:send(body)
    if not ok then return nil, err end
    local deadline = os.time() + (timeout or self.options.timeout or 30)
    repeat
        local packet
        packet, err = self.transport:receive()
        if not packet then return nil, err end
        local decoded
        decoded, err = message.unpack(self.auth_key, self.session_id, packet)
        if not decoded then return nil, err end
        if decoded.salt ~= self.server_salt then
            -- A future bad_server_salt response can safely refresh this value;
            -- don't accept arbitrary salts from ordinary messages.
        end
        local reader = tl.reader(decoded.body)
        local constructor = reader:uint()
        if constructor == RPC_RESULT then
            local request_id = reader:take(8)
            if request_id == raw_id then
                local result = reader:take(#decoded.body - reader.offset + 1)
                local result_reader = tl.reader(result)
                local result_constructor = result_reader:uint()
                if result_constructor == RPC_ERROR then
                    local code, text = result_reader:int(), result_reader:string()
                    return nil, {code = code, message = text, request_id = request_id}
                end
                local ok, value = pcall(wallet_decode.decode, result)
                return {raw = result, constructor = result_constructor,
                    data = ok and value or nil, decoding_error = ok and nil or tostring(value),
                    request_id = raw_id, message_id = decoded.message_id}
            end
        elseif constructor == MSG_CONTAINER then
            local count = reader:int()
            if count < 0 or count > 10000 then return nil, 'invalid MTProto message container' end
            for _ = 1, count do
                reader:long()
                reader:int()
                local inner_id = reader:take(8)
                reader:int()
                local length = reader:int()
                if length < 4 or length % 4 ~= 0 then return nil, 'invalid MTProto container message length' end
                local inner = tl.reader(reader:take(length))
                local inner_constructor = inner:uint()
                if inner_constructor == RPC_RESULT then
                    local request_id = inner:take(8)
                    if request_id == raw_id then
                        local result = inner:take(length - inner.offset + 1)
                        local result_reader = tl.reader(result)
                        local result_constructor = result_reader:uint()
                        if result_constructor == RPC_ERROR then
                            return nil, {code = result_reader:int(), message = result_reader:string(), request_id = raw_id}
                        end
                        local ok, value = pcall(wallet_decode.decode, result)
                        return {raw = result, constructor = result_constructor,
                            data = ok and value or nil, decoding_error = ok and nil or tostring(value),
                            request_id = raw_id, message_id = inner_id}
                    end
                end
            end
        elseif constructor == BAD_SERVER_SALT then
            reader:long(); reader:long(); reader:int(); reader:int()
            self.server_salt = reader:take(8)
            return nil, 'Telegram requested a retry with a new server salt; reconnect and retry the call'
        elseif constructor == NEW_SESSION_CREATED then
            reader:long(); reader:take(8)
            self.server_salt = reader:take(8)
        elseif constructor == PONG then
            reader:long(); reader:long()
        end
        if os.time() >= deadline then return nil, 'timed out waiting for Telegram RPC result' end
    until false
end

function Client:connect()
    assert(self.state == 'disconnected', 'MTProto client must be disconnected before connect')
    local ok, err = self.transport:connect()
    if not ok then return nil, err end
    self.state = 'connected'
    if not self.auth_key then
        local session
        session, err = auth.create_auth_key(self.transport, self.options.dc_id)
        if not session then self:close(); return nil, err end
        self.auth_key, self.auth_key_id = session.auth_key, session.auth_key_id
        self.server_salt, self.session_id = session.server_salt, session.session_id
        self.time_offset = session.server_time_offset
        self.auth_session = session
    end
    if not (self.server_salt and #self.server_salt == 8 and self.session_id and #self.session_id == 8) then
        self:close()
        return nil, 'MTProto session requires an 8-byte server_salt and session_id'
    end
    -- A fresh MTProto session ID lets the per-session sequence counter restart
    -- safely after reconnect while keeping the account auth key.
    self.session_id = crypto.random_bytes(8)
    self.sequence, self.initialized = 0, false
    self.state = self.authorized and 'authorized' or 'auth_key_ready'
    return self.auth_session or {auth_key = self.auth_key, auth_key_id = self.auth_key_id,
        server_salt = self.server_salt, session_id = self.session_id, authorized = self.authorized}
end

function Client:_wrap_init(query)
    assert(self.state == 'authorized' or self.state == 'auth_key_ready', 'connect before initializing Telegram layer')
    assert(type(query) == 'string' and #query > 0 and #query % 4 == 0, 'encoded TL query is required')
    local opts = self.options
    local layer = tl.uint(INVOKE_WITH_LAYER) .. tl.int(opts.layer or wallet.layer)
    if self.initialized then return layer .. query end
    local wrapped = layer .. tl.uint(INIT_CONNECTION) .. tl.int(0) .. tl.int(opts.api_id)
        .. tl.string(opts.device_model or 'Lua client')
        .. tl.string(opts.system_version or _VERSION)
        .. tl.string(opts.app_version or 'titogramlua')
        .. tl.string(opts.system_lang_code or 'en') .. tl.string(opts.lang_pack or '')
        .. tl.string(opts.lang_code or 'en') .. query
    return wrapped
end

function Client:initialize(query)
    assert(self.state == 'authorized' or self.state == 'auth_key_ready', 'connect before initializing Telegram layer')
    assert(type(query) == 'string' and #query > 0 and #query % 4 == 0, 'encoded TL query is required')
    local result, err = self:_encrypted_rpc(self:_wrap_init(query))
    if result or type(err) == 'table' then self.initialized = true end
    return result, err
end

function Client:invoke_api(query)
    assert(self.state == 'auth_key_ready' or self.state == 'authorized', 'connect before calling Telegram API')
    assert(type(query) == 'string' and #query > 0 and #query % 4 == 0, 'encoded TL query is required')
    local result, err = self:_encrypted_rpc(self:_wrap_init(query))
    if result or type(err) == 'table' then self.initialized = true end
    return result, err
end

function Client:invoke(method_name, params)
    assert(self.state == 'authorized' and self.authorized,
        'wallet RPC requires an account-authorized Telegram user session')
    local query = wallet.encode(method_name, params or {})
    return self:initialize(query)
end

local function read_sent_code_type(reader)
    local constructor = reader:uint()
    local value = {constructor = constructor}
    if constructor == 0x3dbb5986 or constructor == 0xc000bba2 or constructor == 0x5353e5a7 then
        value.length = reader:int()
    elseif constructor == 0xab03c6d9 then
        value.pattern = reader:string()
    elseif constructor == 0x82006484 then
        value.prefix, value.length = reader:string(), reader:int()
    elseif constructor == 0xf450f59b then
        local flags = reader:int()
        value.apple_signin_allowed = flags % 2 == 1
        value.google_signin_allowed = math.floor(flags / 2) % 2 == 1
        value.email_pattern = reader:string()
        value.length = reader:int()
        if math.floor(flags / 8) % 2 == 1 then value.reset_available_period = reader:int() end
        if math.floor(flags / 16) % 2 == 1 then value.reset_pending_date = reader:int() end
    elseif constructor == 0xa5491dea then
        local flags = reader:int()
        value.apple_signin_allowed = flags % 2 == 1
        value.google_signin_allowed = math.floor(flags / 2) % 2 == 1
    elseif constructor == 0xd9565c39 then
        value.url, value.length = reader:string(), reader:int()
    elseif constructor == 0xa416ac81 then
        local flags = reader:int()
        if flags % 2 == 1 then value.beginning = reader:string() end
    elseif constructor == 0xb37794af then
        local flags = reader:int()
        if flags % 2 == 1 then value.beginning = reader:string() end
    elseif constructor == 0x9fd736 then
        local flags = reader:int()
        if flags % 2 == 1 then value.nonce = reader:bytes() end
        if math.floor(flags / 4) % 2 == 1 then
            value.play_integrity_project_id, value.play_integrity_nonce = reader:long(), reader:bytes()
        end
        if math.floor(flags / 2) % 2 == 1 then value.receipt, value.push_timeout = reader:string(), reader:int() end
        value.length = reader:int()
    else
        return nil, ('unsupported Telegram sent-code type 0x%08x'):format(constructor)
    end
    return value
end

function Client:send_code(phone_number)
    assert(type(phone_number) == 'string' and phone_number:match('^%+?[0-9]+$'), 'phone_number must be in international format')
    local query = tl.uint(0xa677244f) .. tl.string(phone_number) .. tl.int(self.options.api_id)
        .. tl.string(self.options.api_hash) .. tl.uint(0xad253d78) .. tl.int(0)
    local result, err = self:invoke_api(query)
    if not result then return nil, err end
    local reader = tl.reader(result.raw)
    local constructor = reader:uint()
    if constructor == AUTH_SENT_CODE_SUCCESS then
        local authorization = reader:uint()
        if authorization == AUTHORIZATION then self.authorized = true; self.state = 'authorized' end
        return {authorized = self.authorized, constructor = constructor}
    end
    if constructor ~= AUTH_SENT_CODE then
        return nil, ('unexpected auth.sendCode result 0x%08x'):format(constructor)
    end
    local flags = reader:int()
    local sent_type
    sent_type, err = read_sent_code_type(reader)
    if not sent_type then return nil, err end
    local code_hash = reader:string()
    local next_type
    if math.floor(flags / 2) % 2 == 1 then next_type, err = read_sent_code_type(reader); if not next_type then return nil, err end end
    local timeout
    if math.floor(flags / 4) % 2 == 1 then timeout = reader:int() end
    self.phone_number, self.phone_code_hash = phone_number, code_hash
    return {phone_code_hash = code_hash, type = sent_type, next_type = next_type, timeout = timeout}
end

function Client:sign_in(phone_code, phone_code_hash)
    assert(type(self.phone_number) == 'string', 'call send_code before sign_in')
    assert(type(phone_code) == 'string' and phone_code ~= '', 'phone_code is required')
    phone_code_hash = phone_code_hash or self.phone_code_hash
    assert(type(phone_code_hash) == 'string' and phone_code_hash ~= '', 'phone_code_hash is required')
    local query = tl.uint(0x8d52a951) .. tl.int(1) .. tl.string(self.phone_number)
        .. tl.string(phone_code_hash) .. tl.string(phone_code)
    local result, err = self:invoke_api(query)
    if not result then
        if type(err) == 'table' and err.message and err.message:find(SESSION_PASSWORD_NEEDED, 1, true) then
            return nil, {code = err.code, message = SESSION_PASSWORD_NEEDED, two_factor_required = true}
        end
        return nil, err
    end
    local reader = tl.reader(result.raw)
    local constructor = reader:uint()
    if constructor == AUTH_SIGNUP_REQUIRED then
        return nil, {signup_required = true, message = 'Telegram requires a first and last name to create this account'}
    end
    if constructor == AUTHORIZATION then
        self.authorized, self.state = true, 'authorized'
        return {authorized = true, raw = result.raw}
    end
    return nil, ('unexpected auth.signIn result 0x%08x'):format(constructor)
end

function Client:sign_up(first_name, last_name, no_joined_notifications)
    assert(type(self.phone_number) == 'string' and type(self.phone_code_hash) == 'string',
        'call send_code before sign_up')
    assert(type(first_name) == 'string' and first_name ~= '', 'first_name is required')
    assert(type(last_name) == 'string', 'last_name must be a string')
    local flags = no_joined_notifications and 1 or 0
    local query = tl.uint(0xaac7b717) .. tl.int(flags) .. tl.string(self.phone_number)
        .. tl.string(self.phone_code_hash) .. tl.string(first_name) .. tl.string(last_name)
    local result, err = self:invoke_api(query)
    if not result then return nil, err end
    local reader = tl.reader(result.raw)
    if reader:uint() ~= AUTHORIZATION then return nil, 'unexpected auth.signUp result' end
    self.authorized, self.state = true, 'authorized'
    return {authorized = true, raw = result.raw}
end

function Client:get_password_parameters()
    local result, err = self:invoke_api(tl.uint(0x548a30f5))
    if not result then return nil, err end
    local reader = tl.reader(result.raw)
    if reader:uint() ~= ACCOUNT_PASSWORD then return nil, 'unexpected account.getPassword result' end
    local flags = reader:int()
    if math.floor(flags / 4) % 2 == 0 then return nil, 'this Telegram account does not have a 2FA password' end
    local algo_constructor = reader:uint()
    if algo_constructor ~= PASSWORD_KDF then return nil, 'Telegram returned an unsupported 2FA password algorithm' end
    local kdf = {constructor = algo_constructor, salt1 = reader:bytes(), salt2 = reader:bytes(), g = reader:int(), p = reader:bytes()}
    local srp_b = reader:bytes()
    local srp_id = reader:long()
    return {kdf = kdf, srp_B = srp_b, srp_id = srp_id}
end

function Client:check_password(password, parameters)
    assert(type(password) == 'string' and password ~= '', '2FA password is required')
    local err
    if not parameters then parameters, err = self:get_password_parameters(); if not parameters then return nil, err end end
    local proof = srp.make_check(password, parameters.srp_id, parameters.srp_B, parameters.kdf)
    local result
    result, err = self:invoke_api(tl.uint(0xd18b4d16) .. proof)
    if not result then return nil, err end
    local reader = tl.reader(result.raw)
    if reader:uint() ~= AUTHORIZATION then return nil, 'unexpected auth.checkPassword result' end
    self.authorized, self.state = true, 'authorized'
    return {authorized = true, raw = result.raw}
end

function Client:is_authorized()
    return self.authorized and self.state == 'authorized'
end

function Client:close()
    local ok, err = self.transport:close()
    self.state = 'disconnected'
    self.sequence = 0
    return ok, err
end

Client.methods = wallet.methods
function Client.load_session(options, path, password)
    options = options or {}
    local session, err = SessionStore.load(path, password)
    if not session then return nil, err end
    local merged = {}
    for key, value in pairs(options) do merged[key] = value end
    merged.host = merged.host or session.host
    merged.port = merged.port or session.port
    merged.session = session
    return Client.new(merged)
end

function Client:save_session(path, password)
    assert(self.auth_key and self.server_salt and self.session_id, 'connect before saving an MTProto session')
    return SessionStore.save(path, {
        auth_key = self.auth_key,
        server_salt = self.server_salt,
        session_id = self.session_id,
        dc_id = self.auth_session and self.auth_session.dc_id or self.options.dc_id,
        server_time_offset = self.time_offset,
        authorized = self.authorized,
        host = self.options.host,
        port = self.options.port or 443,
    }, password)
end

return Client
