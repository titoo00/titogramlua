-- MTProto abridged TCP framing. The socket carries TL payloads only; encryption
-- and authorization are provided by the session layer above this transport.
local Transport = {}
Transport.__index = Transport

local MAX_FRAME_WORDS = 0xffffff

local function little_u24(value)
    return string.char(value % 256, math.floor(value / 256) % 256,
        math.floor(value / 65536) % 256)
end

local function read_exact(socket, length)
    local data, err, partial = socket:receive(length)
    if data then return data end
    if partial and #partial > 0 then
        local remaining = length - #partial
        local rest, rest_err, rest_partial = socket:receive(remaining)
        if rest then return partial .. rest end
        return nil, rest_err or err, partial .. (rest_partial or '')
    end
    return nil, err
end

function Transport.new(options)
    options = options or {}
    assert(type(options.host) == 'string' and options.host ~= '', 'Telegram DC host is required')
    local port = options.port or 443
    assert(type(port) == 'number' and port >= 1 and port <= 65535, 'invalid Telegram DC port')
    return setmetatable({host = options.host, port = port, timeout = options.timeout or 30,
        max_frame_bytes = options.max_frame_bytes or 16 * 1024 * 1024}, Transport)
end

function Transport:connect()
    assert(not self.socket, 'MTProto transport is already connected')
    local socket = require('socket')
    local client, err = socket.tcp()
    if not client then return nil, err end
    client:settimeout(self.timeout)
    local ok
    ok, err = client:connect(self.host, self.port)
    if not ok then client:close(); return nil, err end
    self.socket = client
    -- Abridged transport marker; encrypted and unencrypted MTProto payloads
    -- are framed identically after this byte.
    ok, err = client:send('\xef')
    if not ok then self:close(); return nil, err end
    return true
end

function Transport:send(payload)
    assert(self.socket, 'MTProto transport is not connected')
    assert(type(payload) == 'string' and #payload > 0 and #payload % 4 == 0,
        'MTProto payload must be a non-empty multiple of four bytes')
    local words = #payload / 4
    assert(words <= MAX_FRAME_WORDS, 'MTProto payload exceeds abridged frame limit')
    local prefix
    if words < 127 then prefix = string.char(words)
    else prefix = string.char(0x7f) .. little_u24(words) end
    local frame, index = prefix .. payload, 1
    while index <= #frame do
        local sent, err, last = self.socket:send(frame, index)
        if sent then
            index = sent + 1
        else
            if not last or last < index then return nil, err end
            index = last + 1
            if err ~= 'timeout' and index <= #frame then return nil, err end
        end
    end
    return true
end

function Transport:receive()
    assert(self.socket, 'MTProto transport is not connected')
    local marker, err = read_exact(self.socket, 1)
    if not marker then return nil, err end
    local words
    local first = marker:byte(1)
    if first < 127 then words = first
    elseif first == 127 then
        local length
        length, err = read_exact(self.socket, 3)
        if not length then return nil, err end
        local b1, b2, b3 = length:byte(1, 3)
        words = b1 + b2 * 256 + b3 * 65536
    else
        return nil, 'invalid abridged MTProto frame prefix'
    end
    local bytes = words * 4
    if bytes == 0 or bytes > self.max_frame_bytes then
        return nil, 'abridged MTProto frame size is outside configured limits'
    end
    return read_exact(self.socket, bytes)
end

function Transport:close()
    if not self.socket then return true end
    local socket = self.socket
    self.socket = nil
    return socket:close()
end

return Transport

