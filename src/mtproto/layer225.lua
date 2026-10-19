-- Raw MTProto Layer 225 method codec.
-- Nested TL constructors are supplied as objects created below or as {_tl=encoded}.
local tl = require('titogramlua.mtproto.tl')

local M = {layer = 225}
local methods = {
    ['messages.setBotGuestChatResult'] = {id=0xb8f106e3, fields={
        {name='query_id',type='long'}, {name='result',type='object'}}},
    ['messages.deleteParticipantReactions'] = {id=0xa0b80cf8, fields={
        {name='peer',type='object'}, {name='participant',type='object'}}},
    ['messages.deleteParticipantReaction'] = {id=0xe3b7f82c, fields={
        {name='peer',type='object'}, {name='msg_id',type='int'}, {name='participant',type='object'}}},
    ['messages.getPersonalChannelHistory'] = {id=0x55fb0996, fields={
        {name='user_id',type='object'}, {name='limit',type='int'}, {name='max_id',type='int'},
        {name='min_id',type='int'}, {name='hash',type='long'}}},
    ['bots.getAccessSettings'] = {id=0x213853a3, fields={{name='bot',type='object'}}},
    ['bots.editAccessSettings'] = {id=0x31813cd8, fields={
        {name='restricted',type='true',flag=0}, {name='bot',type='object'},
        {name='add_users',type='Vector<object>',flag=1}}},
    ['stats.getPollStats'] = {id=0xc27dfa68, fields={
        {name='dark',type='true',flag=0}, {name='peer',type='object'}, {name='msg_id',type='int'}}},
    ['aicompose.createTone'] = {id=0x4aa83913, fields={
        {name='display_author',type='true',flag=0}, {name='emoji_id',type='long'},
        {name='title',type='string'}, {name='prompt',type='string'}}},
    ['aicompose.updateTone'] = {id=0x903bcf59, fields={
        {name='tone',type='object'}, {name='display_author',type='Bool',flag=0},
        {name='emoji_id',type='long',flag=1}, {name='title',type='string',flag=2},
        {name='prompt',type='string',flag=3}}},
    ['aicompose.saveTone'] = {id=0x1782cbb1, fields={
        {name='tone',type='object'}, {name='unsave',type='Bool'}}},
    ['aicompose.deleteTone'] = {id=0xdd39316a, fields={{name='tone',type='object'}}},
    ['aicompose.getTone'] = {id=0xb2e8ba03, fields={{name='tone',type='object'}}},
    ['aicompose.getTones'] = {id=0xabd59201, fields={{name='hash',type='long'}}},
    ['aicompose.getToneExample'] = {id=0xd1b4ab14, fields={
        {name='tone',type='object'}, {name='num',type='int'}}},
    ['contacts.getTopPeers'] = {id=0x973478b6, fields={
        {name='correspondents',type='true',flag=0}, {name='bots_pm',type='true',flag=1},
        {name='bots_inline',type='true',flag=2}, {name='phone_calls',type='true',flag=3},
        {name='forward_users',type='true',flag=4}, {name='forward_chats',type='true',flag=5},
        {name='groups',type='true',flag=10}, {name='channels',type='true',flag=15},
        {name='bots_app',type='true',flag=16}, {name='bots_guestchat',type='true',flag=17},
        {name='offset',type='int'}, {name='limit',type='int'}, {name='hash',type='long'}}},
    ['messages.composeMessageWithAI'] = {id=0xdaecc589, fields={
        {name='proofread',type='true',flag=0}, {name='emojify',type='true',flag=3},
        {name='text',type='object'}, {name='translate_to_lang',type='string',flag=1},
        {name='tone',type='object',flag=2}}},
}

local function encode_value(kind, value)
    if kind == 'object' then return tl.object(value) end
    if kind == 'Bool' then return tl.bool(value) end
    local vector_kind = kind:match('^Vector<(.+)>$')
    if vector_kind then
        local item = vector_kind == 'object' and tl.object or nil
        assert(item, 'unsupported Layer 225 vector type: ' .. kind)
        return tl.vector(item, value)
    end
    if kind == 'true' then
        assert(value == true, 'TL true values are represented by their flags bit')
        return ''
    end
    local writers = {int=tl.int, long=tl.long, string=tl.string, bytes=tl.bytes}
    local writer = writers[kind]
    assert(writer, 'unsupported Layer 225 TL type: ' .. tostring(kind))
    return writer(value)
end

function M.encode(method_name, params)
    local method = methods[method_name]
    assert(method, 'unknown Layer 225 method: ' .. tostring(method_name))
    assert(type(params) == 'table', 'Layer 225 parameters must be a table')
    local flags, has_flags = 0, false
    for _, field in ipairs(method.fields) do
        if field.flag ~= nil then
            has_flags = true
            local value = params[field.name]
            if value ~= nil and value ~= false then flags = flags + 2 ^ field.flag end
        end
    end
    local out = {tl.uint(method.id)}
    if has_flags then out[#out + 1] = tl.uint(flags) end
    for _, field in ipairs(method.fields) do
        local value = params[field.name]
        if field.flag == nil then
            assert(value ~= nil, method_name .. ' requires parameter ' .. field.name)
            out[#out + 1] = encode_value(field.type, value)
        elseif value ~= nil and value ~= false and field.type ~= 'true' then
            out[#out + 1] = encode_value(field.type, value)
        end
    end
    return table.concat(out)
end

local function object(constructor, ...)
    local parts = {tl.uint(constructor)}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        parts[#parts + 1] = v
    end
    return {_tl=table.concat(parts)}
end

M.objects = {
    input_user = function(id, access_hash)
        return object(0xf21158c6, tl.long(id), tl.long(access_hash))
    end,
    input_user_self = function() return object(0xf7c1b13f) end,
    input_peer_user = function(id, access_hash)
        return object(0xdde8a54c, tl.long(id), tl.long(access_hash))
    end,
    input_peer_chat = function(id) return object(0x35a95cb9, tl.long(id)) end,
    input_peer_channel = function(id, access_hash)
        return object(0x27bcbbfc, tl.long(id), tl.long(access_hash))
    end,
    input_peer_self = function() return object(0x7da07ec9) end,
    input_ai_compose_tone_default = function(tone)
        return object(0x1fe9a9bf, tl.string(tone))
    end,
    input_ai_compose_tone_id = function(id, access_hash)
        return object(0x0773c080, tl.long(id), tl.long(access_hash))
    end,
    input_ai_compose_tone_slug = function(slug)
        return object(0x1fa01357, tl.string(slug))
    end,
}

function M.new(client)
    assert(type(client) == 'table' and type(client.invoke_api) == 'function',
        'expected a connected titogramlua MTProto client')
    return setmetatable({client=client}, {__index=M})
end

function M:call(method_name, params)
    assert(self.client.authorized and self.client.state == 'authorized',
        'Layer 225 methods require an account-authorized MTProto session')
    return self.client:invoke_api(M.encode(method_name, params or {}))
end

M.methods = methods
return M
