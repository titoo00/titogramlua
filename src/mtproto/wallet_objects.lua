-- Constructors for common nested TL objects accepted by wallet.* methods.
local tl = require('titogramlua.mtproto.tl')

local function object(bytes)
    assert(type(bytes) == 'string' and #bytes > 0 and #bytes % 4 == 0, 'invalid encoded TL object')
    return {_tl = bytes}
end

local M = {}
function M.input_user_self()
    return object(tl.uint(0xf7c1b13f))
end

function M.input_user(user_id, access_hash)
    return object(tl.uint(0xf21158c6) .. tl.long(user_id) .. tl.long(access_hash))
end

function M.wallet_new()
    return object(tl.uint(0x63a440dc))
end

function M.wallet_imported(public_key, anchor_public_key, proof)
    assert(type(public_key) == 'string', 'wallet public key is required')
    assert(type(proof) == 'table' and type(proof._tl) == 'string', 'wallet ownership proof is required')
    local flags = anchor_public_key ~= nil and 1 or 0
    return object(tl.uint(0x66a66a3b) .. tl.int(flags) .. tl.bytes(public_key)
        .. (anchor_public_key ~= nil and tl.bytes(anchor_public_key) or '')
        .. tl.object(proof))
end

function M.ownership_proof(timestamp, signature)
    assert(type(timestamp) == 'number' and timestamp % 1 == 0, 'proof timestamp must be an integer')
    assert(type(signature) == 'string', 'proof signature must be bytes')
    return object(tl.uint(0x60bccb0d) .. tl.int(timestamp) .. tl.bytes(signature))
end

function M.input_check_password_srp(srp_id, A, M1)
    assert(type(A) == 'string' and type(M1) == 'string', 'SRP proof fields must be bytes')
    return object(tl.uint(0xd27ff082) .. tl.long(srp_id) .. tl.bytes(A) .. tl.bytes(M1))
end

return M

