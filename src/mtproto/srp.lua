-- Telegram 2FA password proof (SRP-6a variant used by account.getPassword).
local crypto = require('titogramlua.mtproto.crypto')
local big = require('titogramlua.mtproto.bignum')
local tl = require('titogramlua.mtproto.tl')

local M = {}
local PASSWORD_KDF = 0x3a912d4a
local INPUT_CHECK_PASSWORD_SRP = 0xd27ff082

local function password_hash(password, salt1, salt2)
    local hash1 = crypto.sha256(salt1 .. password .. salt1)
    local hash2 = crypto.sha256(salt2 .. hash1 .. salt2)
    local hash3 = crypto.pbkdf2(hash2, salt1, 100000, 'sha512', 64)
    return crypto.sha256(salt2 .. hash3 .. salt2)
end

function M.make_check(password, srp_id, srp_b, kdf)
    assert(type(password) == 'string', '2FA password must be a string')
    assert(type(srp_id) == 'string' or type(srp_id) == 'number', 'srp_id is required')
    assert(type(srp_b) == 'string' and #srp_b > 0 and #srp_b <= 256, 'invalid Telegram srp_B')
    assert(type(kdf) == 'table', 'Telegram password KDF parameters are required')
    assert(kdf.constructor == PASSWORD_KDF, 'Telegram requested an unsupported password KDF')
    assert(#kdf.p == 256 and kdf.g >= 2 and kdf.g <= 7, 'invalid Telegram SRP group parameters')

    local p = big.from_bytes(kdf.p)
    local B = big.from_bytes(srp_b)
    assert(B > 0 and B < p, 'Telegram srp_B is outside the prime group')
    local g = big.from_hex(string.format('%x', kdf.g))
    local p_bytes = kdf.p
    local g_bytes = big.to_bytes(g, 256)
    local x = big.from_bytes(password_hash(password, kdf.salt1, kdf.salt2))
    local gx = big.mod_pow(g, x, p)
    local multiplier = big.from_bytes(crypto.sha256(p_bytes .. g_bytes))
    local kgx = (multiplier * gx) % p
    local a = big.from_bytes(crypto.random_bytes(256))
    local A = big.mod_pow(g, a, p)
    assert(A > 0 and A < p, 'generated Telegram SRP A is outside the prime group')
    local A_bytes = big.to_bytes(A, 256)
    local B_bytes = big.to_bytes(B, 256)
    local u = big.from_bytes(crypto.sha256(A_bytes .. B_bytes))
    assert(u > 0, 'Telegram SRP scrambling parameter is zero')
    local base = (B - kgx) % p
    if base < 0 then base = base + p end
    assert(base > 0, 'invalid Telegram SRP base')
    local shared = big.mod_pow(base, a + u * x, p)
    local shared_bytes = big.to_bytes(shared, 256)
    local key = crypto.sha256(shared_bytes)
    local proof = crypto.sha256(crypto.xor(crypto.sha256(p_bytes), crypto.sha256(g_bytes))
        .. crypto.sha256(kdf.salt1) .. crypto.sha256(kdf.salt2)
        .. A_bytes .. B_bytes .. key)
    return tl.uint(INPUT_CHECK_PASSWORD_SRP) .. tl.long(srp_id)
        .. tl.bytes(A_bytes) .. tl.bytes(proof)
end

function M.password_hash(password, salt1, salt2)
    return password_hash(password, salt1, salt2)
end

return M
