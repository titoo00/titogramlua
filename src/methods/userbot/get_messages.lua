--- Get several messages from one chat.
-- @module titogramlua.methods.userbot.get_messages
-- @usage client:get_messages(chat_id, {message_id_1, message_id_2})
return function(self, chat_id, message_ids)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(type(message_ids) == 'table', 'message_ids must be a table')
    return self:send('getMessages', {chat_id = chat_id, message_ids = message_ids})
end
