-- Password-encrypted portable MTProto session file (AES-256-CBC + HMAC-SHA-256).
local tl = require('titogramlua.mtproto.tl')
local crypto = require('titogramlua.mtproto.crypto')

local M = {}
local MAGIC = 'TITOGRAM-MTPROTO-SESSION-1\0'
local ITERATIONS = 200000

local function cipher(data, key, iv, encrypt)
    local context = require('openssl.cipher').new('aes-256-cbc')
    if encrypt then context:encrypt(key, iv, true) else context:decrypt(key, iv, true) end
    local result, err = context:final(data)
    assert(result, 'OpenSSL session encryption failed: ' .. tostring(err))
    return result
end

local function constant_time_equal(a, b)
    if type(a) ~= 'string' or type(b) ~= 'string' or #a ~= #b then return false end
    local diff = 0
    for i = 1, #a do if a:byte(i) ~= b:byte(i) then diff = diff + 1 end end
    return diff == 0
end

function M.encode(session, password)
    assert(type(session) == 'table' and type(session.auth_key) == 'string' and #session.auth_key == 256,
        'a 256-byte MTProto auth key is required')
    assert(type(session.server_salt) == 'string' and #session.server_salt == 8, 'an 8-byte server salt is required')
    assert(type(session.session_id) == 'string' and #session.session_id == 8, 'an 8-byte session id is required')
    assert(type(password) == 'string' and #password >= 12, 'session password must have at least 12 characters')
    local plain = tl.int(1) .. tl.bytes(session.auth_key) .. tl.bytes(session.server_salt)
        .. tl.bytes(session.session_id) .. tl.int(session.dc_id or 0)
        .. tl.int(session.server_time_offset or 0) .. tl.bool(session.authorized == true)
        .. tl.string(session.host or '') .. tl.int(session.port or 443)
    local salt, iv = crypto.random_bytes(16), crypto.random_bytes(16)
    local material = crypto.pbkdf2(password, salt, ITERATIONS, 'sha512', 64)
    local encrypted = cipher(plain, material:sub(1, 32), iv, true)
    local authenticated = MAGIC .. salt .. iv .. encrypted
    return authenticated .. crypto.hmac(material:sub(33, 64), authenticated, 'sha256')
end

function M.decode(blob, password)
    assert(type(blob) == 'string' and type(password) == 'string', 'session file and password are required')
    local min_length = #MAGIC + 16 + 16 + 16 + 32
    if #blob < min_length or blob:sub(1, #MAGIC) ~= MAGIC then return nil, 'invalid TitogramLua session file' end
    local salt_start = #MAGIC + 1
    local salt = blob:sub(salt_start, salt_start + 15)
    local iv = blob:sub(salt_start + 16, salt_start + 31)
    local encrypted, mac = blob:sub(salt_start + 32, -33), blob:sub(-32)
    if #encrypted == 0 or #encrypted % 16 ~= 0 then return nil, 'invalid encrypted session payload length' end
    local material = crypto.pbkdf2(password, salt, ITERATIONS, 'sha512', 64)
    local authenticated = blob:sub(1, -33)
    if not constant_time_equal(crypto.hmac(material:sub(33, 64), authenticated, 'sha256'), mac) then
        return nil, 'wrong session password or damaged session file'
    end
    local ok, plain = pcall(cipher, encrypted, material:sub(1, 32), iv, false)
    if not ok then return nil, 'session decryption failed' end
    local success, session = pcall(function()
        local reader = tl.reader(plain)
        assert(reader:int() == 1, 'unsupported session version')
        local result = {auth_key = reader:bytes(), server_salt = reader:bytes(), session_id = reader:bytes(),
            dc_id = reader:int(), server_time_offset = reader:int()}
        local bool_constructor = reader:uint()
        assert(bool_constructor == 0x997275b5 or bool_constructor == 0xbc799737, 'invalid authorization flag')
        result.authorized = bool_constructor == 0x997275b5
        result.host, result.port = reader:string(), reader:int()
        assert(#result.auth_key == 256 and #result.server_salt == 8 and #result.session_id == 8, 'invalid session key material')
        return result
    end)
    if not success then return nil, 'invalid session payload: ' .. tostring(session) end
    return session
end

function M.save(path, session, password)
    assert(type(path) == 'string' and path ~= '', 'session file path is required')
    local blob = M.encode(session, password)
    local file, err = io.open(path, 'wb')
    if not file then return nil, err end
    local ok, write_err = file:write(blob)
    local close_ok, close_err = file:close()
    if not ok then return nil, write_err end
    if not close_ok then return nil, close_err end
    return true
end

function M.load(path, password)
    assert(type(path) == 'string' and path ~= '', 'session file path is required')
    local file, err = io.open(path, 'rb')
    if not file then return nil, err end
    local blob = file:read('*a')
    file:close()
    return M.decode(blob, password)
end

return M
