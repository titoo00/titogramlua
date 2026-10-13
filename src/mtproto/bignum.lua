-- OpenSSL BIGNUM helpers for MTProto's RSA/DH handshake.
local bn = require('openssl.bignum')
local crypto = require('titogramlua.mtproto.crypto')

local M = {}

function M.from_bytes(bytes)
    assert(type(bytes) == 'string', 'big integer input must be bytes')
    local value = bn.new(0)
    for i = 1, #bytes do value = value * 256 + bytes:byte(i) end
    return value
end

function M.from_hex(hex)
    assert(type(hex) == 'string' and #hex % 2 == 0 and hex:match('^%x*$'), 'invalid hexadecimal integer')
    return M.from_bytes((hex:gsub('..', function(pair) return string.char(tonumber(pair, 16)) end)))
end

function M.to_bytes(value, width)
    local decimal = tostring(value)
    local negative = decimal:sub(1, 1) == '-'
    assert(not negative, 'unsigned byte conversion cannot encode a negative BIGNUM')
    local bytes, number = {}, value
    repeat
        local remainder = number % 256
        local digit = tonumber(tostring(remainder))
        assert(digit and digit >= 0 and digit < 256, 'OpenSSL BIGNUM remainder conversion failed')
        bytes[#bytes + 1] = string.char(digit)
        number = (number - remainder) / 256
    until number == 0
    if width then
        assert(#bytes <= width, 'BIGNUM does not fit requested byte width')
        while #bytes < width do bytes[#bytes + 1] = '\0' end
    end
    local out = {}
    for i = #bytes, 1, -1 do out[#out + 1] = bytes[i] end
    return table.concat(out)
end

function M.mod_pow(base, exponent, modulus)
    local result = bn.new(1)
    base = base % modulus
    while exponent > 0 do
        if exponent % 2 ~= 0 then result = (result * base) % modulus end
        exponent = (exponent - (exponent % 2)) / 2
        base = (base * base) % modulus
    end
    return result
end

local function gcd(a, b)
    while b ~= 0 do a, b = b, a % b end
    return a
end

local function random_below(limit)
    local width = #M.to_bytes(limit)
    return M.from_bytes(crypto.random_bytes(width)) % limit
end

--- Factor Telegram's at-most-64-bit pq with bounded Pollard rho attempts.
function M.factor_pq(pq_bytes, max_iterations)
    assert(type(pq_bytes) == 'string' and #pq_bytes > 0 and #pq_bytes <= 8,
        'Telegram pq value must be 1 to 8 bytes')
    local n = M.from_bytes(pq_bytes)
    if n % 2 == 0 then return bn.new(2), n / 2 end
    local budget = max_iterations or 200000
    for _ = 1, 16 do
        local x = random_below(n - 3) + 2
        local y, c, divisor, steps = x, random_below(n - 1) + 1, bn.new(1), 0
        while divisor == 1 and steps < budget do
            x = (x * x + c) % n
            y = (y * y + c) % n
            y = (y * y + c) % n
            local difference = x >= y and x - y or y - x
            divisor = gcd(difference, n)
            steps = steps + 1
        end
        if divisor > 1 and divisor < n then
            local other = n / divisor
            if divisor * other == n then
                return divisor < other and divisor or other, divisor < other and other or divisor
            end
        end
    end
    return nil, 'unable to factor Telegram pq within the configured work limit'
end

return M

