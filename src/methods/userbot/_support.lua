--- Shared parameter validation and asynchronous result handling for user methods.
-- @module titogramlua.methods.userbot._support
local support = {}

function support.copy(value)
    assert(value == nil or type(value) == 'table', 'params must be a table')
    local result = {}
    for key, item in pairs(value or {}) do result[key] = item end
    return result
end

local function validate(value, kind, name)
    if value == nil then return end -- TDLib validates method-specific requirements.
    local item = kind:match('^vector<(.+)>$')
    if item then
        assert(type(value) == 'table', name .. ' must be an array')
        local count = 0
        for key, entry in pairs(value) do
            assert(type(key) == 'number' and key >= 1 and key == math.floor(key), name .. ' must be an array')
            count = count + 1
            validate(entry, item, name .. '[' .. key .. ']')
        end
        assert(count == #value, name .. ' must not contain gaps')
    elseif kind == 'int32' or kind == 'int53' or kind == 'int64' then
        if kind == 'int64' and type(value) == 'string' then
            assert(value:match('^%-?%d+$'), name .. ' must be a decimal integer string')
        else
            assert(type(value) == 'number' and value == value and value ~= math.huge
                and value ~= -math.huge and value == math.floor(value), name .. ' must be an integer')
            if kind == 'int32' then
                assert(value >= -2147483648 and value <= 2147483647, name .. ' is outside int32 range')
            else
                assert(math.abs(value) <= 9007199254740991, name .. ' is not exact; use a string for int64 IDs')
            end
        end
    elseif kind == 'double' then
        assert(type(value) == 'number' and value == value and math.abs(value) ~= math.huge,
            name .. ' must be a finite number')
    elseif kind == 'Bool' then
        assert(type(value) == 'boolean', name .. ' must be a boolean')
    elseif kind == 'string' or kind == 'bytes' then
        assert(type(value) == 'string', name .. ' must be a string (base64 for bytes)')
    else
        assert(type(value) == 'table' and type(value['@type']) == 'string', name .. ' must be a TDLib ' .. kind .. ' object')
    end
end

function support.params(value, fields, defaults, fixed)
    local params = support.copy(value)
    for key, item in pairs(defaults or {}) do
        if params[key] == nil then params[key] = item end
    end
    for key, item in pairs(fixed or {}) do params[key] = item end
    for key, item in pairs(params) do
        assert(fields[key], 'unknown parameter: ' .. tostring(key))
        validate(item, fields[key], key)
    end
    return params
end

function support.finish(self, callback, result, err, name)
    if callback then callback(result, err, self)
    elseif self.on_result then self.on_result(result, err, name, self)
    elseif err and (type(err) ~= 'table' or err['@extra'] == nil) then
        require('titogramlua.methods.userbot._events').emit(self, 'error', err)
    end
end

function support.method(name, fields, defaults, fixed, project)
    return function(self, params, callback)
        if type(params) == 'function' and callback == nil then callback, params = params, nil end
        assert(callback == nil or type(callback) == 'function', 'callback must be a function')
        params = support.params(params, fields, defaults, fixed)
        if callback or project then
            return self:request(name, params, function(result, err, client)
                if not err and project then result = project(result) end
                support.finish(client, callback, result, err, name)
            end)
        end
        return self:send(name, params)
    end
end

function support.formatted(text, entities)
    if type(text) == 'table' then
        assert(text['@type'] == 'formattedText', 'text must be a formattedText object')
        return text
    end
    assert(text == nil or type(text) == 'string', 'text must be a string or formattedText')
    return {['@type'] = 'formattedText', text = text or '', entities = entities or {}}
end

function support.input_file(file)
    if type(file) == 'string' then return {['@type'] = 'inputFileLocal', path = file} end
    if type(file) == 'number' then return {['@type'] = 'inputFileId', id = file} end
    assert(type(file) == 'table' and type(file['@type']) == 'string', 'file must be an InputFile, local path, or file ID')
    return file
end

function support.send_content(self, chat_id, content, opts, callback)
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    assert(chat_id ~= nil, 'chat_id is required')
    assert(type(content) == 'table' and content['@type'], 'content must be an InputMessageContent object')
    local method, params = 'sendMessage', {
        chat_id = chat_id, topic_id = opts.topic_id, reply_to = opts.reply_to,
        options = opts.send_options, reply_markup = opts.reply_markup, input_message_content = content,
    }
    if opts.business_connection_id then
        method = 'sendBusinessMessage'
        params = {
            business_connection_id = opts.business_connection_id, chat_id = chat_id,
            reply_to = opts.reply_to, disable_notification = opts.disable_notification == true,
            protect_content = opts.protect_content == true, effect_id = opts.effect_id or 0,
            reply_markup = opts.reply_markup, input_message_content = content,
        }
    elseif opts.receiver_user_id then
        method = 'sendEphemeralMessage'
        params = {
            chat_id = chat_id, topic_id = opts.topic_id, receiver_user_id = opts.receiver_user_id,
            callback_query_id = opts.callback_query_id or '0',
            replace_callback_query_message = opts.replace_callback_query_message == true,
            reply_to = opts.reply_to, protect_content = opts.protect_content == true,
            sending_id = opts.sending_id or 0, only_preview = opts.only_preview == true,
            reply_markup = opts.reply_markup, input_message_content = content,
        }
    end
    if callback then return self:request(method, params, callback) end
    return self:send(method, params)
end

function support.media(content_type, field, input_type, input_fields, content_fields)
    return function(self, chat_id, media, opts, callback)
        opts = opts or {}
        assert(type(opts) == 'table', 'opts must be a table')
        if content_type == 'inputMessagePhoto' and field == 'photo' then
            assert(opts.video ~= nil or (type(media) == 'table' and media.video ~= nil),
                'send_live_photo requires a video InputFile in opts.video or inputPhoto.video')
        end
        local input = media
        if not (type(input) == 'table' and input['@type'] == input_type) then
            input = {['@type'] = input_type, [field] = support.input_file(media)}
            for key, kind in pairs(input_fields) do
                if key ~= field then
                    local value = opts[key]
                    if value == nil then
                        if kind == 'Bool' then value = false
                        elseif kind == 'int32' or kind == 'double' then value = 0
                        elseif kind == 'string' or kind == 'bytes' then value = ''
                        elseif kind:match('^vector') then value = {} end
                    end
                    validate(value, kind, key)
                    input[key] = value
                end
            end
        end
        local content = {['@type'] = content_type, [field] = input}
        for key, kind in pairs(content_fields) do
            if key ~= field then
                local value = opts[key]
                if key == 'caption' then value = support.formatted(value, opts.entities)
                elseif value == nil and kind == 'Bool' then value = false end
                validate(value, kind, key)
                content[key] = value
            end
        end
        return support.send_content(self, chat_id, content, opts, callback)
    end
end

function support.content(content_type, fields, defaults)
    return function(self, chat_id, values, opts, callback)
        local content = support.copy(values)
        if content['@type'] ~= nil then
            assert(content['@type'] == content_type, 'content must be ' .. content_type)
            content['@type'] = nil
        end
        for key, kind in pairs(fields) do
            if kind == 'formattedText' and type(content[key]) == 'string' then
                content[key] = support.formatted(content[key])
            end
        end
        content = support.params(content, fields, defaults)
        content['@type'] = content_type
        return support.send_content(self, chat_id, content, opts, callback)
    end
end

function support.state(self, params, update_type, select, callback, name)
    return self:request('getCurrentState', {}, function(result, err, client)
        if err then return support.finish(client, callback, nil, err, name) end
        for _, update in ipairs(result.updates or {}) do
            if update['@type'] == update_type then
                local value = select(update, params or {})
                if value ~= nil then return support.finish(client, callback, value, nil, name) end
            end
        end
        support.finish(client, callback, nil, {['@type'] = 'error', code = 404,
            message = 'TDLib has no cached ' .. update_type .. '; wait for the corresponding update'}, name)
    end)
end

return support
