-- Decoders for the wallet TL results whose payloads are self-contained custom
-- constructors. Results with generated Telegram objects retain their raw bytes.
local tl = require('titogramlua.mtproto.tl')

local M = {}
local function flag(flags, bit) return math.floor(flags / (2 ^ bit)) % 2 == 1 end

local function decode_peer(reader)
    local constructor = reader:uint()
    if constructor == 0xd4ea706d then
        local flags = reader:int()
        local peer = {kind = 'user', user_id = reader:long(), address = reader:string()}
        if flag(flags, 0) then peer.domain = reader:string() end
        return peer
    elseif constructor == 0x062cc1bc then
        local flags = reader:int()
        local peer = {kind = 'address', address = reader:string()}
        if flag(flags, 0) then peer.domain = reader:string() end
        return peer
    elseif constructor == 0xe595186e then
        local flags = reader:int()
        local peer = {kind = 'onramp', address = reader:string()}
        if flag(flags, 0) then peer.domain = reader:string() end
        peer.provider_name = reader:string()
        return peer
    elseif constructor == 0x728bed5a then return {kind = 'unsupported'} end
    error(('unsupported wallet transaction peer 0x%08x'):format(constructor))
end

local function decode_transaction(reader)
    local constructor = reader:uint()
    assert(constructor == 0x952dc143, 'unexpected wallet transaction constructor')
    local flags = reader:int()
    local transaction = {
        incoming = flag(flags, 0), gasless = flag(flags, 1), failed = flag(flags, 2),
        key_change = flag(flags, 5), comment_encrypted = flag(flags, 6),
        id = reader:string(), amount = reader:long(), fee = reader:long(), date = reader:int(),
        peer = decode_peer(reader),
    }
    if flag(flags, 3) then transaction.comment = reader:string() end
    if flag(flags, 4) then transaction.tx_hash = reader:string() end
    if flag(flags, 7) then
        error('wallet transaction contains an NFT object; returning the full response as raw TL')
    end
    return transaction
end

local function decode_web_document(reader)
    local constructor = reader:uint()
    local document
    if constructor == 0x1c570ed1 then
        document = {kind = 'web_document', url = reader:string(), access_hash = reader:long(),
            size = reader:int(), mime_type = reader:string()}
    elseif constructor == 0xf9c8bcc6 then
        document = {kind = 'web_document_no_proxy', url = reader:string(),
            size = reader:int(), mime_type = reader:string()}
    else
        error(('unsupported WebDocument constructor 0x%08x'):format(constructor))
    end
    document.attributes = reader:vector(function(input)
        local attribute = input:uint()
        if attribute == 0x6c37c15c then
            return {kind = 'image_size', width = input:int(), height = input:int()}
        elseif attribute == 0x15590068 then
            return {kind = 'filename', name = input:string()}
        elseif attribute == 0x11b58939 then
            return {kind = 'animated'}
        elseif attribute == 0x9801d2f7 then
            return {kind = 'has_stickers'}
        end
        error(('unsupported WebDocument attribute 0x%08x'):format(attribute))
    end)
    return document
end

local function decode_nft(reader)
    assert(reader:uint() == 0x3441fd1c, 'unexpected wallet NFT constructor')
    local flags = reader:int()
    local nft = {}
    if flag(flags, 0) then nft.collection_address = reader:string() end
    nft.address, nft.owner_address, nft.index = reader:string(), reader:string(), reader:string()
    if flag(flags, 1) then nft.name = reader:string() end
    if flag(flags, 2) then nft.description = reader:string() end
    if flag(flags, 3) then nft.image = decode_web_document(reader) end
    if flag(flags, 4) then nft.image_small = decode_web_document(reader) end
    if flag(flags, 5) then nft.content_url = decode_web_document(reader) end
    if flag(flags, 6) then nft.lottie = decode_web_document(reader) end
    if flag(flags, 7) then
        nft.attributes = reader:vector(function(input)
            assert(input:uint() == 0x4c1ef10e, 'unexpected wallet NFT attribute constructor')
            return {trait_type = input:string(), value = input:string()}
        end)
    end
    if flag(flags, 8) then
        assert(reader:uint() == 0x7d748d04, 'unexpected wallet NFT extra JSON constructor')
        nft.extra = reader:string()
    end
    return nft
end

local function decode_ton_connect_session(reader)
    assert(reader:uint() == 0x126556c6, 'unexpected TON Connect session constructor')
    local flags = reader:int()
    local session = {pending = flag(flags, 0), closing = flag(flags, 1), closed = flag(flags, 2),
        id = reader:long(), dapp_client_id = reader:string()}
    if flag(flags, 3) then session.client_id = reader:string() end
    session.nonce = reader:bytes()
    if flag(flags, 4) then
        assert(reader:uint() == 0x12229264, 'unexpected TON Connect manifest constructor')
        local manifest_flags = reader:int()
        session.manifest = {url = reader:string(), name = reader:string()}
        if flag(manifest_flags, 0) then session.manifest.icon = decode_web_document(reader) end
    end
    if flag(flags, 5) then session.manifest_error = reader:int() end
    session.date = reader:int()
    return session
end

local function decode_ton_connect_request(reader)
    assert(reader:uint() == 0xa15f8513, 'unexpected TON Connect request constructor')
    local flags = reader:int()
    local request = {session_id = reader:long(), msg_id = reader:int(), body = reader:bytes(), expires = reader:int()}
    if flag(flags, 0) then request.topic = reader:string() end
    if flag(flags, 1) then request.trace_id = reader:string() end
    return request
end

function M.decode(raw)
    assert(type(raw) == 'string' and #raw >= 4, 'wallet TL result is truncated')
    local reader = tl.reader(raw)
    local constructor = reader:uint()
    local result = {constructor = constructor, raw = raw}
    if constructor == 0x9cb9b2ec then
        local flags = reader:int()
        result.kind, result.creating = 'empty', flag(flags, 0)
    elseif constructor == 0x95c5346b then
        local flags = reader:int()
        result.kind = 'wallet_state'
        result.backup_enabled, result.can_export_phrase, result.can_enable_backup = flag(flags, 0), flag(flags, 1), flag(flags, 2)
        result.address, result.public_key, result.balance = reader:string(), reader:bytes(), reader:long()
    elseif constructor == 0x99e41707 then
        result.payload, result.expires, result.domain = reader:string(), reader:int(), reader:string()
    elseif constructor == 0xe6d0ef01 then
        result.token = reader:string()
        result.dcs = reader:vector(function(input) return input:int() end)
    elseif constructor == 0x18e82537 then
        result.data = reader:bytes()
    elseif constructor == 0xbde90a8d then
        local flags = reader:int()
        result.has_balance, result.url = flag(flags, 0), reader:string()
    elseif constructor == 0xf9d612ef then
        result.dc, result.public_key = reader:int(), reader:bytes()
    elseif constructor == 0x928e7b55 then
        result.addresses = reader:vector(function(input)
            assert(input:uint() == 0xfe78eecc, 'unexpected wallet user address constructor')
            local flags, address = input:int(), {}
            if flag(flags, 0) then address.user_id = input:long() end
            address.address, address.public_key = input:string(), input:bytes()
            return address
        end)
        if reader.offset <= #raw then result.users_raw = reader:take(#raw - reader.offset + 1) end
    elseif constructor == 0x4322d5a5 then
        local flags = reader:int()
        result.balance = reader:long()
        result.transactions = reader:vector(function(input)
            local transaction, incomplete = decode_transaction(input)
            if incomplete then result.decoding_incomplete = true end
            return transaction
        end)
        if flag(flags, 0) then result.next_offset = reader:string() end
        -- Chats and users need Telegram's generated object schema. Keep that tail
        -- intact rather than misparsing it or discarding the original response.
        if reader.offset <= #raw then result.related_objects_raw = reader:take(#raw - reader.offset + 1) end
    elseif constructor == 0x794d486f then
        local flags = reader:int()
        result.items = reader:vector(decode_nft)
        if flag(flags, 0) then result.next_offset = reader:string() end
    elseif constructor == 0xe1f6896 then
        result.sessions = reader:vector(decode_ton_connect_session)
    elseif constructor == 0x85c0f124 then
        result.session = decode_ton_connect_session(reader)
        result.requests = reader:vector(decode_ton_connect_request)
    elseif constructor == 0x582464e3 then
        result.event_id = reader:long()
    elseif constructor == 0x997275b5 then
        result.value = true
    elseif constructor == 0xbc799737 then
        result.value = false
    else
        result.decoding_incomplete = true
    end
    return result
end

return M
