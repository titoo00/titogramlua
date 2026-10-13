-- MTProto 2.0 encrypted message envelope.
local tl = require('titogramlua.mtproto.tl')
local crypto = require('titogramlua.mtproto.crypto')

local M = {}

local function make_msg_key(auth_key, data, outgoing)
    local offset = outgoing and 89 or 97
    return crypto.sha256(auth_key:sub(offset, offset + 31) .. data):sub(9, 24)
end

function M.pack(auth_key, session_id, salt, message_id, seq_no, body)
    assert(type(auth_key) == 'string' and #auth_key == 256, 'MTProto auth key must be 256 bytes')
    assert(type(session_id) == 'string' and #session_id == 8, 'MTProto session id must be 8 bytes')
    assert(type(salt) == 'string' and #salt == 8, 'MTProto server salt must be 8 bytes')
    assert(type(message_id) == 'string' and #message_id == 8, 'MTProto message id must be 8 bytes')
    assert(type(body) == 'string' and #body > 0 and #body % 4 == 0, 'TL body must be 4-byte aligned')
    local data = salt .. session_id .. message_id .. tl.int(seq_no) .. tl.int(#body) .. body
    local padding_length = (16 - ((#data + 12) % 16)) % 16 + 12
    local plaintext = data .. crypto.random_bytes(padding_length)
    local msg_key = make_msg_key(auth_key, plaintext, true)
    local key, iv = crypto.kdf(auth_key, msg_key, true)
    local auth_key_id = crypto.sha1(auth_key):sub(13, 20)
    return auth_key_id .. msg_key .. crypto.ige(plaintext, key, iv, true)
end

function M.unpack(auth_key, session_id, packet)
    assert(type(auth_key) == 'string' and #auth_key == 256, 'MTProto auth key must be 256 bytes')
    assert(type(session_id) == 'string' and #session_id == 8, 'MTProto session id must be 8 bytes')
    assert(type(packet) == 'string' and #packet >= 56 and (#packet - 24) % 16 == 0,
        'invalid MTProto encrypted packet length')
    local auth_key_id, msg_key, ciphertext = packet:sub(1, 8), packet:sub(9, 24), packet:sub(25)
    if auth_key_id ~= crypto.sha1(auth_key):sub(13, 20) then return nil, 'MTProto auth key id mismatch' end
    local key, iv = crypto.kdf(auth_key, msg_key, false)
    local plaintext = crypto.ige(ciphertext, key, iv, false)
    if make_msg_key(auth_key, plaintext, false) ~= msg_key then return nil, 'MTProto message key check failed' end

    local reader = tl.reader(plaintext)
    local salt = reader:take(8)
    if reader:take(8) ~= session_id then return nil, 'MTProto session id mismatch' end
    local message_id_raw = reader:take(8)
    local seq_no = reader:int()
    local length = reader:int()
    if length < 4 or length % 4 ~= 0 or length > #plaintext - 32 then
        return nil, 'invalid MTProto inner message length'
    end
    local body = reader:take(length)
    local padding = #plaintext - 32 - length
    if padding < 12 or padding > 1024 then return nil, 'invalid MTProto message padding length' end
    if message_id_raw:byte(1) % 4 ~= 1 then return nil, 'invalid incoming MTProto message id' end
    return {salt = salt, message_id = message_id_raw, seq_no = seq_no, body = body, padding_length = padding}
end

return M
