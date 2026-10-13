-- MTProto cryptographic primitives using OpenSSL through luaossl.
local M = {}

local function digest(name, data)
    local ctx = require('openssl.digest').new(name)
    ctx:update(data)
    return ctx:final()
end

function M.sha1(data) return digest('sha1', data) end
function M.sha256(data) return digest('sha256', data) end
function M.sha512(data) return digest('sha512', data) end

function M.hmac(key, data, digest_name)
    local signer = require('openssl.hmac').new(key, digest_name or 'sha256')
    signer:update(data)
    return signer:final()
end

function M.pbkdf2(password, salt, iterations, digest_name, output_length)
    assert(type(password) == 'string' and type(salt) == 'string', 'PBKDF2 password and salt must be bytes')
    assert(type(iterations) == 'number' and iterations >= 1 and iterations % 1 == 0, 'invalid PBKDF2 iterations')
    digest_name = digest_name or 'sha512'
    output_length = output_length or 64
    local digest_length = digest_name == 'sha512' and 64 or digest_name == 'sha256' and 32
    assert(digest_length and output_length > 0, 'unsupported PBKDF2 digest or output length')
    local output, blocks = {}, math.ceil(output_length / digest_length)
    for block = 1, blocks do
        local n = string.char(math.floor(block / 16777216) % 256,
            math.floor(block / 65536) % 256, math.floor(block / 256) % 256, block % 256)
        local u = M.hmac(password, salt .. n, digest_name)
        local result = u
        for _ = 2, iterations do
            u = M.hmac(password, u, digest_name)
            result = M.xor(result, u)
        end
        output[#output + 1] = result
    end
    return table.concat(output):sub(1, output_length)
end

function M.random_bytes(size)
    local value = require('openssl.rand').bytes(size)
    assert(type(value) == 'string' and #value == size, 'OpenSSL secure random generator failed')
    return value
end

function M.xor(a, b)
    assert(type(a) == 'string' and type(b) == 'string' and #a == #b, 'xor inputs must have equal lengths')
    local out = {}
    for i = 1, #a do
        local x, y, bit, value = a:byte(i), b:byte(i), 1, 0
        for _ = 1, 8 do
            if x % 2 ~= y % 2 then value = value + bit end
            x, y, bit = math.floor(x / 2), math.floor(y / 2), bit * 2
        end
        out[i] = string.char(value)
    end
    return table.concat(out)
end

local function aes_block(block, key, encrypt)
    assert(#block == 16 and #key == 32, 'AES-256 block/key size mismatch')
    local cipher = require('openssl.cipher').new('aes-256-ecb')
    if encrypt then cipher:encrypt(key, nil, false) else cipher:decrypt(key, nil, false) end
    local result, err = cipher:final(block)
    assert(result and #result == 16, 'OpenSSL AES block operation failed: ' .. tostring(err))
    return result
end

function M.ige(data, key, iv, encrypt)
    assert(type(data) == 'string' and #data % 16 == 0, 'AES-IGE data must be 16-byte aligned')
    assert(type(iv) == 'string' and #iv == 32, 'AES-IGE IV must be 32 bytes')
    assert(type(key) == 'string' and #key == 32, 'AES-IGE key must be 32 bytes')
    local prev_a, prev_b = iv:sub(1, 16), iv:sub(17, 32)
    local output = {}
    for offset = 1, #data, 16 do
        local block = data:sub(offset, offset + 15)
        if encrypt then
            local encrypted = M.xor(aes_block(M.xor(block, prev_a), key, true), prev_b)
            output[#output + 1], prev_a, prev_b = encrypted, encrypted, block
        else
            local plain = M.xor(aes_block(M.xor(block, prev_b), key, false), prev_a)
            output[#output + 1], prev_a, prev_b = plain, block, plain
        end
    end
    return table.concat(output)
end

function M.kdf(auth_key, msg_key, outgoing)
    assert(#auth_key == 256 and #msg_key == 16, 'invalid MTProto auth key or message key length')
    local x = outgoing and 0 or 8
    local sha_a = M.sha256(msg_key .. auth_key:sub(x + 1, x + 36))
    local sha_b = M.sha256(auth_key:sub(x + 41, x + 76) .. msg_key)
    local key = sha_a:sub(1, 8) .. sha_b:sub(9, 24) .. sha_a:sub(25, 32)
    local iv = sha_b:sub(1, 8) .. sha_a:sub(9, 24) .. sha_b:sub(25, 32)
    return key, iv
end

return M

