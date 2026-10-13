-- Telegram MTProto auth-key handshake. A created auth key is not a signed-in
-- Telegram user account; account authorization is a separate protocol flow.
local tl = require('titogramlua.mtproto.tl')
local crypto = require('titogramlua.mtproto.crypto')
local big = require('titogramlua.mtproto.bignum')
local server_keys = require('titogramlua.mtproto.server_keys')

local M = {}
local REQ_PQ_MULTI = 0xbe7e8ef1
local RES_PQ = 0x05162463
local RPC_ERROR = 0x2144ca19
local REQ_DH_PARAMS = 0xd712e4be
local SERVER_DH_PARAMS_OK = 0xd0e8075c
local SERVER_DH_PARAMS_FAIL = 0x79cb045d
local SET_CLIENT_DH_PARAMS = 0xf5045f1f
local DH_GEN_OK = 0x3bcbf734
local DH_GEN_RETRY = 0x46dc1fb9
local DH_GEN_FAIL = 0xa69dae02

local DH_PRIME_HEX = table.concat({
    'C71CAEB9C6B1C9048E6C522F70F13F73980D40238E3E21C14934D037563D930F',
    '48198A0AA7C14058229493D22530F4DBFA336F6E0AC925139543AED44CCE7C37',
    '20FD51F69458705AC68CD4FE6B6B13ABDC9746512969328454F18FAF8C595F64',
    '2477FE96BB2A941D5BCD1D4AC8CC49880708FA9B378E3C4F3A9060BEE67CF9A4',
    'A4A695811051907E162753B56B0F6B410DBA74D8A84B2A14B3144E0EF1284754',
    'FD17ED950D5965B4B9DD46582DB1178D169C6BC465B0D6FF9CA3928FEF5B9AE4',
    'E418FC15E83EBEA0F87FA9FF5EED70050DED2849F47BF959D956850CE929851F',
    '0D8115F635B105EE2E4E15D04B2454BF6F4FADF034B10403119CD8E3B92FCC5B',
})

local function random_bytes(count)
    local random = require('openssl.rand')
    local bytes = random.bytes(count)
    assert(type(bytes) == 'string' and #bytes == count,
        'OpenSSL did not return the requested number of secure random bytes')
    return bytes
end

local last_plain_seconds, plain_counter = 0, 0
local function next_plain_message_id()
    -- MTProto message ids have the current Unix time in the high 32 bits and
    -- zero in the low bits for client requests. Emit the exact bytes without
    -- converting the 64-bit value through a Lua double.
    local seconds = os.time()
    if seconds > last_plain_seconds then
        last_plain_seconds, plain_counter = seconds, 0
    else
        plain_counter = plain_counter + 1
    end
    return tl.uint((plain_counter * 4) % 0x100000000) .. tl.uint(seconds)
end

local function send_plain(transport, body)
    assert(#body % 4 == 0, 'plain MTProto query must be 4-byte aligned')
    local packet = string.rep('\0', 8) .. next_plain_message_id() .. tl.int(#body) .. body
    return transport:send(packet)
end

local function receive_plain(transport)
    local packet, err = transport:receive()
    if not packet then return nil, err end
    if #packet < 20 then return nil, 'truncated plain MTProto response header' end
    local reader = tl.reader(packet)
    local auth_key_id = reader:take(8)
    if auth_key_id ~= string.rep('\0', 8) then
        return nil, 'expected a plain MTProto response with auth_key_id zero'
    end
    local msg_id = reader:long()
    local length = reader:int()
    if length < 4 or length > 1024 * 1024 or length ~= #packet - 20 then
        return nil, 'invalid plain MTProto response length'
    end
    return reader:take(length), msg_id
end

--- Send req_pq_multi and validate the server's ResPQ response.
-- @param transport connected titogramlua.mtproto.transport instance
-- @return table|nil response containing nonce, server_nonce, pq, fingerprints
-- @return string|nil error
function M.request_pq(transport)
    assert(type(transport) == 'table' and type(transport.send) == 'function'
        and type(transport.receive) == 'function', 'connected MTProto transport is required')
    local nonce = random_bytes(16)
    local body = tl.uint(REQ_PQ_MULTI) .. nonce
    local ok, err = send_plain(transport, body)
    if not ok then return nil, err end

    local response
    response, err = receive_plain(transport)
    if not response then return nil, err end
    local reader = tl.reader(response)
    local constructor = reader:uint()
    if constructor == RPC_ERROR then
        local code, message = reader:int(), reader:string()
        return nil, ('Telegram RPC error %d: %s'):format(code, message)
    end
    if constructor ~= RES_PQ then
        return nil, ('unexpected MTProto handshake constructor 0x%08x'):format(constructor)
    end

    local echoed_nonce = reader:take(16)
    if echoed_nonce ~= nonce then return nil, 'Telegram ResPQ nonce does not match the request' end
    local server_nonce = reader:take(16)
    local pq = reader:bytes()
    local fingerprints = reader:vector(function(input) return input:long() end)
    if #pq == 0 or #fingerprints == 0 then
        return nil, 'Telegram ResPQ response omitted pq or RSA fingerprints'
    end
    return {nonce = nonce, server_nonce = server_nonce, pq = pq,
        fingerprints = fingerprints, message_id = 'resPQ'}
end

local function secure_plain_rpc(transport, body)
    local ok, err = send_plain(transport, body)
    if not ok then return nil, err end
    local response
    response, err = receive_plain(transport)
    if not response then return nil, err end
    return tl.reader(response)
end

local function read_error(reader, constructor)
    if constructor ~= RPC_ERROR then return nil end
    local code, message = reader:int(), reader:string()
    return ('Telegram RPC error %d: %s'):format(code, message)
end

local function rsa_encrypt(data, fingerprint)
    local key = server_keys[fingerprint]
    if not key then return nil, 'Telegram advertised an RSA fingerprint not in the pinned key set' end
    local digest = crypto.sha1(data)
    local padding_size = (255 - ((#digest + #data) % 255)) % 255
    local padded = digest .. data .. crypto.random_bytes(padding_size)
    if #padded ~= 255 then return nil, 'invalid MTProto RSA padding size' end
    local modulus = big.from_hex(key.n)
    local result = big.mod_pow(big.from_bytes(padded), key.e, modulus)
    return big.to_bytes(result, 256)
end

--- Complete Telegram's temporary auth-key creation exchange for one DC.
-- This creates a valid MTProto auth key, but does not sign a user account in.
function M.create_auth_key(transport, dc_id)
    assert(type(dc_id) == 'number' and dc_id % 1 == 0, 'dc_id is required')
    local pq_result, err = M.request_pq(transport)
    if not pq_result then return nil, err end
    local fingerprint
    for _, candidate in ipairs(pq_result.fingerprints) do
        if server_keys[candidate] then fingerprint = candidate; break end
    end
    if not fingerprint then return nil, 'no matching pinned Telegram RSA public key was advertised by this DC' end

    local p, q = big.factor_pq(pq_result.pq)
    if not p then return nil, q end
    local p_bytes, q_bytes = big.to_bytes(p, 4), big.to_bytes(q, 4)
    local new_nonce = random_bytes(32)
    local inner_data = tl.uint(0xa9f55f95) .. tl.bytes(pq_result.pq) .. tl.bytes(p_bytes)
        .. tl.bytes(q_bytes) .. pq_result.nonce .. pq_result.server_nonce .. new_nonce .. tl.int(dc_id)
    local encrypted_data
    encrypted_data, err = rsa_encrypt(inner_data, fingerprint)
    if not encrypted_data then return nil, err end

    local req_dh = tl.uint(REQ_DH_PARAMS) .. pq_result.nonce .. pq_result.server_nonce
        .. tl.bytes(p_bytes) .. tl.bytes(q_bytes) .. tl.long(fingerprint) .. tl.bytes(encrypted_data)
    local reader
    reader, err = secure_plain_rpc(transport, req_dh)
    if not reader then return nil, err end
    local constructor = reader:uint()
    local rpc_error = read_error(reader, constructor)
    if rpc_error then return nil, rpc_error end
    if constructor == SERVER_DH_PARAMS_FAIL then
        return nil, 'Telegram rejected the RSA handshake (server_DH_params_fail)'
    end
    if constructor ~= SERVER_DH_PARAMS_OK then return nil, 'unexpected Telegram DH params response' end
    if reader:take(16) ~= pq_result.nonce or reader:take(16) ~= pq_result.server_nonce then
        return nil, 'Telegram DH response nonce mismatch'
    end
    local encrypted_answer = reader:bytes()
    local sha_a = crypto.sha1(new_nonce .. pq_result.server_nonce)
    local sha_b = crypto.sha1(pq_result.server_nonce .. new_nonce)
    local tmp_key = sha_a .. sha_b:sub(1, 12)
    local tmp_iv = sha_b:sub(13, 20) .. crypto.sha1(new_nonce .. new_nonce) .. new_nonce:sub(1, 4)
    if #encrypted_answer % 16 ~= 0 then return nil, 'invalid encrypted Telegram DH answer length' end
    local answer = crypto.ige(encrypted_answer, tmp_key, tmp_iv, false)
    local answer_hash, answer_data = answer:sub(1, 20), answer:sub(21)
    local answer_reader = tl.reader(answer_data)
    if answer_reader:uint() ~= 0xb5890dba then return nil, 'unexpected Telegram DH inner data constructor' end
    if answer_reader:take(16) ~= pq_result.nonce or answer_reader:take(16) ~= pq_result.server_nonce then
        return nil, 'Telegram DH inner data nonce mismatch'
    end
    local g, dh_prime_bytes, g_a_bytes = answer_reader:int(), answer_reader:bytes(), answer_reader:bytes()
    local server_time = answer_reader:int()
    if crypto.sha1(answer_data:sub(1, answer_reader.offset - 1)) ~= answer_hash then
        return nil, 'Telegram DH inner data SHA-1 check failed'
    end

    local dh_prime = big.from_bytes(dh_prime_bytes)
    if dh_prime ~= big.from_hex(DH_PRIME_HEX) then return nil, 'Telegram supplied an untrusted DH prime' end
    if g < 2 or g > 7 then return nil, 'Telegram supplied an invalid DH generator' end
    local p_bn = dh_prime
    local g_a = big.from_bytes(g_a_bytes)
    local margin = big.mod_pow(big.from_hex('2'), 1984, p_bn)
    if g_a <= margin or g_a >= p_bn - margin then return nil, 'Telegram supplied an unsafe g_a value' end

    local b = big.from_bytes(crypto.random_bytes(256))
    local g_b = big.mod_pow(big.from_hex(tostring(g)), b, p_bn)
    local g_b_bytes = big.to_bytes(g_b, 256)
    local client_inner = tl.uint(0x6643b654) .. pq_result.nonce .. pq_result.server_nonce
        .. tl.long('0') .. tl.bytes(g_b_bytes)
    local client_hash = crypto.sha1(client_inner)
    local client_padding = (16 - ((#client_hash + #client_inner) % 16)) % 16
    local encrypted_client = crypto.ige(client_hash .. client_inner .. crypto.random_bytes(client_padding),
        tmp_key, tmp_iv, true)
    local set_dh = tl.uint(SET_CLIENT_DH_PARAMS) .. pq_result.nonce .. pq_result.server_nonce
        .. tl.bytes(encrypted_client)
    reader, err = secure_plain_rpc(transport, set_dh)
    if not reader then return nil, err end
    constructor = reader:uint()
    rpc_error = read_error(reader, constructor)
    if rpc_error then return nil, rpc_error end
    if constructor ~= DH_GEN_OK then
        if constructor == DH_GEN_RETRY or constructor == DH_GEN_FAIL then
            return nil, ('Telegram DH authorization failed (0x%08x)'):format(constructor)
        end
        return nil, 'unexpected Telegram DH authorization response'
    end
    if reader:take(16) ~= pq_result.nonce or reader:take(16) ~= pq_result.server_nonce then
        return nil, 'Telegram DH completion nonce mismatch'
    end
    local new_nonce_hash = reader:take(16)
    local auth_key = big.to_bytes(big.mod_pow(g_a, b, p_bn), 256)
    local aux_hash = crypto.sha1(auth_key):sub(1, 8)
    local expected_hash = crypto.sha1(new_nonce .. string.char(1) .. aux_hash):sub(5, 20)
    if new_nonce_hash ~= expected_hash then return nil, 'Telegram DH completion hash mismatch' end
    local server_salt = crypto.xor(new_nonce:sub(1, 8), pq_result.server_nonce:sub(1, 8))
    return {auth_key = auth_key, auth_key_id = crypto.sha1(auth_key):sub(13, 20),
        server_salt = server_salt, session_id = random_bytes(8), dc_id = dc_id,
        server_time_offset = server_time - os.time()}
end

M._send_plain = send_plain
M._receive_plain = receive_plain
return M

