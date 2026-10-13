-- Minimal, dependency-free TL writer for generated MTProto schemas.
-- Integers are encoded little-endian as required by Telegram's TL format.
local M = {}
local unpack_values = table.unpack or unpack

local function u32(n)
    assert(type(n) == 'number' and n % 1 == 0 and n >= 0 and n <= 0xffffffff,
        'expected unsigned 32-bit integer')
    return string.char(n % 256, math.floor(n / 256) % 256,
        math.floor(n / 65536) % 256, math.floor(n / 16777216) % 256)
end

function M.int(value)
    assert(type(value) == 'number' and value % 1 == 0 and
        value >= -0x80000000 and value <= 0x7fffffff, 'expected signed 32-bit integer')
    return u32(value < 0 and value + 0x100000000 or value)
end

function M.uint(value)
    return u32(value)
end

local function decimal_bytes(value)
    if type(value) == 'number' then
        assert(value % 1 == 0 and math.abs(value) <= 9007199254740991,
            '64-bit Lua numbers must be exact; pass larger values as decimal strings')
        value = string.format('%.0f', value)
    end
    assert(type(value) == 'string' and value:match('^-?%d+$'), 'expected 64-bit integer or decimal string')
    local negative = value:sub(1, 1) == '-'
    local digits = negative and value:sub(2) or value
    local bytes = {0, 0, 0, 0, 0, 0, 0, 0}
    for i = 1, #digits do
        local carry = tonumber(digits:sub(i, i))
        for j = 1, 8 do
            local n = bytes[j] * 10 + carry
            bytes[j], carry = n % 256, math.floor(n / 256)
        end
        assert(carry == 0, '64-bit integer is out of range')
    end
    if negative then
        for i = 1, 8 do bytes[i] = 255 - bytes[i] end
        for i = 1, 8 do
            bytes[i] = bytes[i] + 1
            if bytes[i] <= 255 then break end
            bytes[i] = 0
        end
    end
    return string.char(unpack_values(bytes))
end

function M.long(value)
    return decimal_bytes(value)
end

function M.bytes(value)
    assert(type(value) == 'string', 'expected byte string')
    local n = #value
    local prefix, header
    if n < 254 then
        prefix, header = string.char(n), 1
    else
        assert(n <= 0xffffff, 'TL byte string exceeds the 24-bit length limit')
        prefix = string.char(254, n % 256, math.floor(n / 256) % 256, math.floor(n / 65536) % 256)
        header = 4
    end
    local padding = (4 - ((header + n) % 4)) % 4
    return prefix .. value .. string.rep('\0', padding)
end

function M.string(value)
    assert(type(value) == 'string', 'expected string')
    return M.bytes(value)
end

function M.bool(value)
    assert(type(value) == 'boolean', 'expected boolean')
    return u32(value and 0x997275b5 or 0xbc799737)
end

function M.vector(encode_item, values)
    assert(type(encode_item) == 'function' and type(values) == 'table', 'expected vector encoder and array')
    local out = {u32(0x1cb5c415), M.int(#values)}
    for i = 1, #values do out[#out + 1] = encode_item(values[i]) end
    return table.concat(out)
end

-- Wrap an already encoded TL object. Use only for objects produced by this codec
-- or by a compatible schema encoder; arbitrary user bytes are not a TL object.
function M.object(value)
    assert(type(value) == 'table' and type(value._tl) == 'string',
        'nested TL values must be encoded objects with a _tl byte string')
    return value._tl
end

local Reader = {}
Reader.__index = Reader

function M.reader(data)
    assert(type(data) == 'string', 'TL input must be a byte string')
    return setmetatable({data = data, offset = 1}, Reader)
end

function Reader:take(length)
    assert(type(length) == 'number' and length >= 0 and length % 1 == 0, 'invalid TL read length')
    local last = self.offset + length - 1
    assert(last <= #self.data, 'truncated TL response')
    local value = self.data:sub(self.offset, last)
    self.offset = last + 1
    return value
end

function Reader:uint()
    local b1, b2, b3, b4 = self:take(4):byte(1, 4)
    return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

function Reader:int()
    local value = self:uint()
    return value >= 0x80000000 and value - 0x100000000 or value
end

local function decimal_from_bytes(bytes, negative)
    local digits = {0}
    for i = #bytes, 1, -1 do
        local carry = bytes[i]
        for j = 1, #digits do
            local n = digits[j] * 256 + carry
            digits[j], carry = n % 10, math.floor(n / 10)
        end
        while carry > 0 do
            digits[#digits + 1], carry = carry % 10, math.floor(carry / 10)
        end
    end
    local chars = {}
    for i = #digits, 1, -1 do chars[#chars + 1] = tostring(digits[i]) end
    local result = table.concat(chars):gsub('^0+(%d)', '%1')
    if negative and result ~= '0' then result = '-' .. result end
    return result
end

function Reader:long()
    local raw = {self:take(8):byte(1, 8)}
    local negative = raw[8] >= 128
    if negative then
        for i = 1, 8 do raw[i] = 255 - raw[i] end
        for i = 1, 8 do
            raw[i] = raw[i] + 1
            if raw[i] <= 255 then break end
            raw[i] = 0
        end
    end
    return decimal_from_bytes(raw, negative)
end

function Reader:bytes()
    local first = self:take(1):byte(1)
    local length, header
    if first < 254 then
        length, header = first, 1
    else
        assert(first == 254, 'invalid TL byte string length marker')
        local b1, b2, b3 = self:take(3):byte(1, 3)
        length, header = b1 + b2 * 256 + b3 * 65536, 4
    end
    local value = self:take(length)
    local padding = (4 - ((header + length) % 4)) % 4
    self:take(padding)
    return value
end

Reader.string = Reader.bytes

function Reader:vector(decode_item)
    assert(self:uint() == 0x1cb5c415, 'invalid TL vector constructor')
    local count = self:int()
    assert(count >= 0 and count <= 1000000, 'invalid TL vector length')
    local result = {}
    for i = 1, count do result[i] = decode_item(self) end
    return result
end

M.Reader = Reader

return M

