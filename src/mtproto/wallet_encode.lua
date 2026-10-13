local tl = require('titogramlua.mtproto.tl')
local schema = require('titogramlua.mtproto.wallet_schema')

local primitive = {
    int = tl.int,
    long = tl.long,
    string = tl.string,
    bytes = tl.bytes,
    object = tl.object,
}

local function encode_type(kind, value)
    local vector_kind = kind:match('^Vector<(.+)>$')
    if vector_kind then
        local encode_item = primitive[vector_kind]
        if not encode_item then
            assert(vector_kind ~= 'true', 'Vector<true> is not a valid TL vector type')
            encode_item = tl.object
        end
        return tl.vector(encode_item, value)
    end
    if kind == 'true' then
        assert(value == true, 'TL true fields are represented by their flags bit')
        return ''
    end
    local encode = primitive[kind]
    if not encode then encode = tl.object end
    return encode(value)
end

local function encode_flags(fields, params)
    local flags, flags2 = 0, 0
    for _, field in ipairs(fields) do
        if field.flag ~= nil and params[field.name] ~= nil and params[field.name] ~= false then
            local word, bit = field.flag2 and 2 or 1, field.flag
            if word == 1 then flags = flags + 2 ^ bit else flags2 = flags2 + 2 ^ bit end
        end
    end
    return flags, flags2
end

local function encode(name, params)
    local method = schema.methods[name]
    assert(method, 'unknown wallet method: ' .. tostring(name))
    assert(type(params) == 'table', 'wallet method parameters must be a table')
    local flags, flags2 = encode_flags(method.fields, params)
    local out = {tl.uint(method.id)}
    local has_flags, has_flags2 = false, false
    for _, field in ipairs(method.fields) do
        if field.flag ~= nil then
            if field.flag2 then has_flags2 = true else has_flags = true end
        end
    end
    if has_flags then out[#out + 1] = tl.uint(flags) end
    if has_flags2 then out[#out + 1] = tl.uint(flags2) end
    for _, field in ipairs(method.fields) do
        local value = params[field.name]
        if field.flag == nil then
            assert(value ~= nil, method.name .. ' requires parameter ' .. field.name)
            out[#out + 1] = encode_type(field.type, value)
        elseif value ~= nil and value ~= false then
            if field.type ~= 'true' then out[#out + 1] = encode_type(field.type, value) end
        end
    end
    return table.concat(out)
end

return {
    encode = encode,
    methods = schema.methods,
    layer = schema.layer,
}
