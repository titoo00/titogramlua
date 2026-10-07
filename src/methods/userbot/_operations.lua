--- Composed operations for the TDLib user client.
-- @module titogramlua.methods.userbot._operations
local support = require('titogramlua.methods.userbot._support')
local events = require('titogramlua.methods.userbot._events')
local operations = {}

local function finish(self, callback, name)
    assert(callback == nil or type(callback) == 'function', 'callback must be a function')
    return function(result, err, client) support.finish(client or self, callback, result, err, name) end
end

local function batch(self, list, method, make_params, callback)
    assert(type(list) == 'table', 'IDs must be an array')
    local requests, results, remaining, first_error = {}, {}, #list, nil
    if remaining == 0 then support.finish(self, callback, results, nil, method); return requests end
    for i, value in ipairs(list) do
        local params = make_params(value)
        if callback or self.on_result then
            requests[i] = self:request(method, params, function(result, err)
                results[i] = result or false
                first_error = first_error or err
                remaining = remaining - 1
                if remaining == 0 then support.finish(self, callback, results, first_error, method) end
            end)
        else requests[i] = self:send(method, params) end
    end
    return requests
end

function operations.archive_chats(self, params, callback)
    params = support.params(params, {chat_ids = 'vector<int53>'})
    return batch(self, assert(params.chat_ids, 'chat_ids is required'), 'addChatToList', function(id)
        return {chat_id = id, chat_list = {['@type'] = 'chatListArchive'}}
    end, callback)
end

function operations.unarchive_chats(self, params, callback)
    params = support.params(params, {chat_ids = 'vector<int53>'})
    return batch(self, assert(params.chat_ids, 'chat_ids is required'), 'addChatToList', function(id)
        return {chat_id = id, chat_list = {['@type'] = 'chatListMain'}}
    end, callback)
end

function operations.get_forum_topics_by_id(self, params, callback)
    params = support.params(params, {chat_id = 'int53', forum_topic_ids = 'vector<int32>'})
    assert(params.chat_id, 'chat_id is required')
    return batch(self, assert(params.forum_topic_ids, 'forum_topic_ids is required'), 'getForumTopic', function(id)
        return {chat_id = params.chat_id, forum_topic_id = id}
    end, callback)
end

function operations.get_direct_messages_topics_by_id(self, params, callback)
    params = support.params(params, {chat_id = 'int53', topic_ids = 'vector<int53>'})
    assert(params.chat_id, 'chat_id is required')
    return batch(self, assert(params.topic_ids, 'topic_ids is required'), 'getDirectMessagesChatTopic', function(id)
        return {chat_id = params.chat_id, topic_id = id}
    end, callback)
end

function operations.join_chat(self, params, callback)
    if type(params) == 'number' then params = {chat_id = params}
    elseif type(params) == 'string' then
        if params:match('^https?://') or params:match('^tg://') then params = {invite_link = params}
        else params = {username = params:gsub('^@', '')} end
    end
    params = support.params(params, {chat_id = 'int53', invite_link = 'string', username = 'string'})
    local done = finish(self, callback, 'join_chat')
    if params.invite_link then return self:request('joinChatByInviteLink', {invite_link = params.invite_link}, done) end
    if params.chat_id then return self:request('joinChat', {chat_id = params.chat_id}, done) end
    assert(params.username, 'provide chat_id, username, or invite_link')
    return self:request('searchPublicChat', {username = params.username}, function(chat, err, client)
        if err then return done(nil, err, client) end
        client:request('joinChat', {chat_id = chat.id}, done)
    end)
end

function operations.get_chat_members_count(self, params, callback)
    params = support.params(params, {chat_id = 'int53'})
    assert(params.chat_id, 'chat_id is required')
    local done = finish(self, callback, 'get_chat_members_count')
    return self:request('getChat', params, function(chat, err, client)
        if err then return done(nil, err, client) end
        local kind = chat.type and chat.type['@type']
        local method, fields
        if kind == 'chatTypeBasicGroup' then method, fields = 'getBasicGroup', {basic_group_id = chat.type.basic_group_id}
        elseif kind == 'chatTypeSupergroup' then method, fields = 'getSupergroupFullInfo', {supergroup_id = chat.type.supergroup_id}
        else return done(nil, {['@type'] = 'error', code = 400, message = 'member count requires a group or channel'}, client) end
        client:request(method, fields, function(info, failure)
            done(info and info.member_count, failure, client)
        end)
    end)
end

function operations.get_chat_online_count(self, params, callback)
    params = support.params(params, {chat_id = 'int53'})
    assert(params.chat_id, 'chat_id is required')
    return support.state(self, params, 'updateChatOnlineMemberCount', function(update, options)
        if update.chat_id == options.chat_id then return update.online_member_count end
    end, callback, 'get_chat_online_count')
end

function operations.get_folders(self, params, callback)
    support.params(params, {})
    return support.state(self, {}, 'updateChatFolders', function(update) return update.chat_folders end,
        callback, 'get_folders')
end

function operations.get_dialogs_count(self, params, callback)
    params = support.params(params, {chat_list = 'ChatList'}, {chat_list = {['@type'] = 'chatListMain'}})
    return support.state(self, params, 'updateUnreadChatCount', function(update, options)
        local a, b = update.chat_list, options.chat_list
        if a and a['@type'] == b['@type'] and a.chat_folder_id == b.chat_folder_id then return update.total_count end
    end, callback, 'get_dialogs_count')
end

function operations.get_available_effects(self, params, callback)
    support.params(params, {})
    return support.state(self, {}, 'updateAvailableMessageEffects', function(update)
        return {reaction_effect_ids = update.reaction_effect_ids, sticker_effect_ids = update.sticker_effect_ids}
    end, callback, 'get_available_effects')
end

function operations.set_bot_default_privileges(self, params, callback)
    params = support.params(params, {privileges = 'chatAdministratorRights', for_channels = 'Bool'})
    local rights = params.privileges or {['@type'] = 'chatAdministratorRights'}
    local method = params.for_channels and 'setDefaultChannelAdministratorRights' or 'setDefaultGroupAdministratorRights'
    local key = params.for_channels and 'default_channel_administrator_rights' or 'default_group_administrator_rights'
    if callback then return self:request(method, {[key] = rights}, callback) end
    return self:send(method, {[key] = rights})
end

function operations.get_bot_default_privileges(self, params, callback)
    params = support.params(params, {user_id = 'int53', for_channels = 'Bool'})
    local done = finish(self, callback, 'get_bot_default_privileges')
    local function read(user_id)
        return self:request('getUserFullInfo', {user_id = user_id}, function(info, err, client)
            if err then return done(nil, err, client) end
            if not info.bot_info then
                return done(nil, {['@type'] = 'error', code = 400, message = 'the selected user is not a bot'}, client)
            end
            done(params.for_channels and info.bot_info.default_channel_administrator_rights
                or info.bot_info.default_group_administrator_rights, nil, client)
        end)
    end
    if params.user_id then return read(params.user_id) end
    return self:request('getMe', {}, function(user, err, client)
        if err then return done(nil, err, client) end
        read(user.id)
    end)
end

function operations.send_phone_number_code(self, params, callback)
    params = support.params(params, {phone_number = 'string', settings = 'phoneNumberAuthenticationSettings', type = 'PhoneNumberCodeType'})
    assert(params.phone_number, 'phone_number is required')
    self._phone_code_type = params.type
    local method = params.type and 'sendPhoneNumberCode' or 'setAuthenticationPhoneNumber'
    if callback then return self:request(method, params, callback) end
    return self:send(method, params)
end

function operations.resend_phone_number_code(self, params, callback)
    params = support.params(params, {reason = 'ResendCodeReason'})
    local method = self._phone_code_type and 'resendPhoneNumberCode' or 'resendAuthenticationCode'
    if callback then return self:request(method, params, callback) end
    return self:send(method, params)
end

function operations.send_recovery_code(self, params, callback)
    support.params(params, {})
    local method = self.authorized and 'requestPasswordRecovery' or 'requestAuthenticationPasswordRecovery'
    if callback then return self:request(method, {}, callback) end
    return self:send(method)
end

function operations.recover_password(self, params, callback)
    params = support.params(params, {recovery_code = 'string', new_password = 'string', new_hint = 'string'})
    local method = self.authorized and 'recoverPassword' or 'recoverAuthenticationPassword'
    if callback then return self:request(method, params, callback) end
    return self:send(method, params)
end

function operations.resolve_peer(self, params, callback)
    if type(params) == 'number' then params = {chat_id = params}
    elseif type(params) == 'string' then
        if params == 'me' or params == 'self' then params = {me = true}
        elseif params:match('^%+%d+$') then params = {phone_number = params}
        else params = {username = params:gsub('^@', '')} end
    end
    params = support.params(params, {chat_id = 'int53', user_id = 'int53', phone_number = 'string', username = 'string', me = 'Bool'})
    local done = finish(self, callback, 'resolve_peer')
    if params.chat_id then return self:request('getChat', {chat_id = params.chat_id}, done) end
    if params.user_id then return self:request('createPrivateChat', {user_id = params.user_id, force = false}, done) end
    if params.username then return self:request('searchPublicChat', {username = params.username}, done) end
    local method, fields
    if params.phone_number then method, fields = 'searchUserByPhoneNumber', {phone_number = params.phone_number, only_local = false}
    else assert(params.me, 'provide chat_id, user_id, username, phone_number, or me'); method, fields = 'getMe', {} end
    return self:request(method, fields, function(user, err, client)
        if err then return done(nil, err, client) end
        client:request('createPrivateChat', {user_id = user.id, force = false}, done)
    end)
end

function operations.read_chat_history(self, params, callback)
    params = support.params(params, {chat_id = 'int53', message_ids = 'vector<int53>', topic_id = 'MessageTopic'})
    assert(params.chat_id, 'chat_id is required')
    local done = finish(self, callback, 'read_chat_history')
    local function read(ids)
        if #ids == 0 then return done({['@type'] = 'ok'}, nil, self) end
        return self:request('viewMessages', {chat_id = params.chat_id, message_ids = ids,
            source = {['@type'] = 'messageSourceChatHistory'}, force_read = true}, done)
    end
    if params.message_ids then return read(params.message_ids) end
    assert(params.topic_id == nil, 'supply message_ids when marking a specific topic as read')
    return self:request('getChat', {chat_id = params.chat_id}, function(chat, err, client)
        if err then return done(nil, err, client) end
        read(chat.last_message and {chat.last_message.id} or {})
    end)
end

function operations.search_posts_count(self, params, callback)
    params = support.params(params, {query = 'string', offset = 'string', limit = 'int32', star_count = 'int53'},
        {offset = '', limit = 100, star_count = 0})
    local done, count, seen = finish(self, callback, 'search_posts_count'), 0, {}
    local function next_page()
        local offset = params.offset
        if seen[offset] then return done(nil, {['@type'] = 'error', code = 500, message = 'repeated public-post search offset'}, self) end
        seen[offset] = true
        return self:request('searchPublicPosts', support.copy(params), function(page, err, client)
            if err then return done(nil, err, client) end
            count = count + #(page.messages or {})
            if not page.next_offset or page.next_offset == '' then return done(count, nil, client) end
            params.offset = page.next_offset
            -- Payment is explicit and applies only to the first search request.
            params.star_count = 0
            next_page()
        end)
    end
    return next_page()
end

function operations.send_paid_reaction(self, params, callback)
    params = support.params(params, {chat_id = 'int53', message_id = 'int53', star_count = 'int53', type = 'PaidReactionType'})
    local done = finish(self, callback, 'send_paid_reaction')
    return self:request('addPendingPaidMessageReaction', params, function(result, err, client)
        if err then return done(nil, err, client) end
        client:request('commitPendingPaidMessageReactions', {chat_id = params.chat_id, message_id = params.message_id}, done)
    end)
end

function operations.add_handler(self, handler, group)
    assert(type(handler) == 'table', 'handler must contain event and callback')
    return events.add(self, handler.event, handler.callback, {group = group or handler.group, filter = handler.filter})
end

function operations.remove_handler(self, handler)
    for i, item in ipairs(self._handlers or {}) do
        if item == handler then table.remove(self._handlers, i); return true end
    end
    return false
end

function operations.unbound_arguments(self, filter, group)
    assert(filter == nil or type(filter) == 'function', 'filter must be a function')
    return {filter = filter, group = group or 0}
end

function operations.start(self)
    assert(not self._closed, 'user client is closed')
    local id = self:send('getAuthorizationState')
    if not self._started then self._started = true; events.emit(self, 'start') end
    return self, id
end

function operations.restart(self)
    local opts, handlers = support.copy(self._opts), self._handlers
    local callbacks = {}
    for key, value in pairs(self) do
        local name = type(key) == 'string' and key:match('^on_(.+)$')
        if name and type(value) == 'function' and value ~= events.registrars[name] then callbacks[key] = value end
    end
    self:close()
    local client = require('titogramlua.methods.userbot').new(opts)
    client._handlers = handlers or {}
    client._handler_sequence = self._handler_sequence
    for key, value in pairs(callbacks) do client[key] = value end
    client:start()
    return client
end

function operations.compose(self, params)
    assert(type(params) == 'table' and type(params.clients) == 'table', 'params.clients must be an array of clients')
    local clients = params.clients
    if params.sequential then for _, client in ipairs(clients) do client:run() end; return clients end
    for _, client in ipairs(clients) do
        assert(not client._closed and not client._running, 'clients must be open and idle')
    end
    local ok, err = pcall(function()
        for _, client in ipairs(clients) do client:start(); client._running = true end
        while true do
            local active = false
            for _, client in ipairs(clients) do
                if client._running and not client._closed then client:receive(0.05); active = true end
            end
            if not active then break end
        end
    end)
    local stop_failure
    for _, client in ipairs(clients) do
        client._running, client._started = false, false
        local stopped, failure = pcall(events.emit, client, 'stop')
        if not stopped and not stop_failure then stop_failure = failure end
    end
    if not ok then error(err, 0) end
    if stop_failure then error(stop_failure, 0) end
    return clients
end

function operations.invoke(self, query, callback)
    assert(type(query) == 'table' and type(query['@type']) == 'string', 'query must be a TDLib request with @type')
    local method = query['@type']
    assert(method:match('^%l[%w]*$'), 'invoke accepts TDLib method names, not Pyrogram raw MTProto constructors')
    local params = support.copy(query)
    params['@type'], params['@extra'] = nil, nil
    if callback then return self:request(method, params, callback) end
    return self:send(method, params)
end

function operations.save_file(self, params, callback)
    params = support.copy(params)
    params.file = support.input_file(params.file)
    params = support.params(params, {file = 'InputFile', file_type = 'FileType', priority = 'int32'}, {priority = 16})
    if callback then return self:request('preliminaryUploadFile', params, callback) end
    return self:send('preliminaryUploadFile', params)
end

function operations.get_media_group(self, params, callback)
    params = support.params(params, {chat_id = 'int53', message_id = 'int53'})
    assert(params.chat_id and params.message_id, 'chat_id and message_id are required')
    local done = finish(self, callback, 'get_media_group')
    return self:request('getMessage', params, function(message, err, client)
        if err then return done(nil, err, client) end
        local album = message.media_album_id
        if album == nil or tostring(album) == '0' then
            return done(nil, {['@type'] = 'error', code = 400, message = 'message does not belong to an album'}, client)
        end
        -- TDLib server MessageId uses server_id << 20 (td/telegram/MessageId.h).
        -- Gate the range lookup to cloud server IDs; local/unsent/scheduled IDs
        -- use a different layout and must not be treated as server IDs.
        local step, max_id = 1048576, 2147483647 * 1048576
        if message.id <= 0 or message.id > max_id or message.id % step ~= 0 then
            return done(nil, {['@type'] = 'error', code = 400,
                message = 'album lookup requires an acknowledged cloud message ID'}, client)
        end
        local ids = {}
        for offset = -9, 9 do
            local id = message.id + offset * step
            if id > 0 and id <= max_id then ids[#ids + 1] = id end
        end
        client:request('getMessages', {chat_id = params.chat_id, message_ids = ids}, function(result, failure)
            if failure then return done(nil, failure, client) end
            local messages = {}
            for _, entry in ipairs(result.messages or {}) do
                if type(entry) == 'table' and entry.id and tostring(entry.media_album_id) == tostring(album) then
                    messages[#messages + 1] = entry
                end
            end
            table.sort(messages, function(a, b) return a.id < b.id end)
            done(messages, nil, client)
        end)
    end)
end

local function forward_album(self, params, callback, copy)
    params = support.params(params, {chat_id = 'int53', from_chat_id = 'int53', message_id = 'int53',
        topic_id = 'MessageTopic', options = 'messageSendOptions', remove_caption = 'Bool'})
    assert(params.chat_id and params.from_chat_id and params.message_id, 'chat_id, from_chat_id, and message_id are required')
    local done = finish(self, callback, copy and 'copy_media_group' or 'forward_media_group')
    return operations.get_media_group(self, {chat_id = params.from_chat_id, message_id = params.message_id}, function(messages, err, client)
        if err then return done(nil, err, client) end
        local ids = {}
        for _, message in ipairs(messages) do ids[#ids + 1] = message.id end
        client:request('forwardMessages', {chat_id = params.chat_id, topic_id = params.topic_id,
            from_chat_id = params.from_chat_id, message_ids = ids, options = params.options,
            send_copy = copy, remove_caption = params.remove_caption == true}, done)
    end)
end

function operations.copy_media_group(self, params, callback) return forward_album(self, params, callback, true) end
function operations.forward_media_group(self, params, callback) return forward_album(self, params, callback, false) end

function operations.send_media_group(self, params, callback)
    params = support.params(params, {chat_id = 'int53', topic_id = 'MessageTopic', reply_to = 'InputMessageReplyTo',
        options = 'messageSendOptions', input_message_contents = 'vector<InputMessageContent>'})
    assert(type(params.input_message_contents) == 'table' and #params.input_message_contents >= 2
        and #params.input_message_contents <= 10, 'an album must contain 2-10 InputMessageContent objects')
    if callback then return self:request('sendMessageAlbum', params, callback) end
    return self:send('sendMessageAlbum', params)
end

function operations.send_cached_media(self, chat_id, content, opts, callback)
    return support.send_content(self, chat_id, content, opts, callback)
end

function operations.send_web_page(self, chat_id, url, opts, callback)
    assert(type(url) == 'string' and url ~= '', 'url must be a non-empty string')
    opts = opts or {}
    local preview = support.copy(opts.link_preview_options)
    preview['@type'], preview.url, preview.is_disabled = 'linkPreviewOptions', url, false
    return support.send_content(self, chat_id, {['@type'] = 'inputMessageText',
        text = support.formatted(opts.text or url, opts.entities), link_preview_options = preview,
        clear_draft = opts.clear_draft == true}, opts, callback)
end

function operations.edit_ephemeral_message_text(self, params, callback)
    params = support.params(params, {chat_id = 'int53', receiver_user_id = 'int53', ephemeral_message_id = 'int32',
        reply_markup = 'ReplyMarkup', text = 'string', entities = 'vector<textEntity>', link_preview_options = 'linkPreviewOptions'})
    assert(params.text ~= nil, 'text is required')
    local request = {chat_id = params.chat_id, receiver_user_id = params.receiver_user_id,
        ephemeral_message_id = params.ephemeral_message_id, reply_markup = params.reply_markup,
        input_message_content = {['@type'] = 'inputMessageText', text = support.formatted(params.text, params.entities),
            link_preview_options = params.link_preview_options, clear_draft = false}}
    if callback then return self:request('editEphemeralMessage', request, callback) end
    return self:send('editEphemeralMessage', request)
end

function operations.stop_transmission(self, params, callback)
    params = support.params(params, {file_id = 'int32', upload = 'Bool', generation_id = 'int64'})
    local method, request
    if params.generation_id then
        method, request = 'finishFileGeneration', {generation_id = params.generation_id,
            error = {['@type'] = 'error', code = 400, message = 'cancelled by the application'}}
    else
        assert(params.file_id, 'file_id or generation_id is required')
        if self._streams and self._streams[params.file_id] then self._streams[params.file_id].cancelled = true end
        method = params.upload and 'cancelPreliminaryUploadFile' or 'cancelDownloadFile'
        request = {file_id = params.file_id}
        if not params.upload then request.only_if_pending = false end
    end
    if callback then return self:request(method, request, callback) end
    return self:send(method, request)
end

function operations.stream_media(self, params, callback)
    params = support.params(params, {file_id = 'int32', offset = 'int53', limit = 'int53', chunk_size = 'int32', priority = 'int32'},
        {offset = 0, limit = 0, chunk_size = 65536, priority = 16})
    assert(params.file_id and params.file_id > 0, 'file_id must be positive')
    assert(type(callback) == 'function', 'callback(chunk, err, client) is required; nil chunk signals EOF')
    assert(params.offset >= 0 and params.limit >= 0 and params.chunk_size > 0, 'invalid byte range or chunk size')
    self._streams = self._streams or {}
    assert(not self._streams[params.file_id], 'a stream is already active for this file')
    local state = {offset = params.offset, read = 0}
    self._streams[params.file_id] = state
    local function complete(err)
        self._streams[params.file_id] = nil
        callback(nil, err, self)
    end
    local function next_chunk()
        if self._closed or state.cancelled then return complete({['@type'] = 'error', code = 499, message = 'stream cancelled'}) end
        local count = params.chunk_size
        if params.limit > 0 then count = math.min(count, params.limit - state.read) end
        if state.size and state.size > 0 then count = math.min(count, state.size - state.offset) end
        if count <= 0 then return complete(nil) end
        return self:request('downloadFile', {file_id = params.file_id, priority = params.priority,
            offset = state.offset, limit = count, synchronous = true}, function(file, err, client)
            if err then return complete(err) end
            if state.cancelled or client._closed then return complete({['@type'] = 'error', code = 499, message = 'stream cancelled'}) end
            state.size = file.size
            client:request('readFilePart', {file_id = params.file_id, offset = state.offset, count = count}, function(result, failure)
                if failure then return complete(failure) end
                local encoded = result.data
                local data = encoded == '' and '' or (type(encoded) == 'string' and require('mime').unb64(encoded))
                if not data then return complete({['@type'] = 'error', code = 500, message = 'invalid file data'}) end
                if #data == 0 then return complete(nil) end
                state.offset, state.read = state.offset + #data, state.read + #data
                local ok, keep_going = pcall(callback, data, nil, client)
                if not ok then
                    self._streams[params.file_id] = nil
                    error(keep_going, 0)
                end
                if keep_going == false then return complete(nil) end
                next_chunk()
            end)
        end)
    end
    return next_chunk()
end

return operations
