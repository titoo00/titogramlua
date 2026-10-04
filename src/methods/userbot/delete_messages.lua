--- Delete messages from a chat.
-- @module titogramlua.methods.userbot.delete_messages
-- @usage client:delete_messages(chat_id, {message_id}, true) -- revoke for everyone when allowed
return function(self, chat_id, message_ids, revoke)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(type(message_ids) == 'table', 'message_ids must be a table')
    return self:send('deleteMessages', {
        chat_id = chat_id,
        message_ids = message_ids,
        revoke = revoke == true
    })
end
