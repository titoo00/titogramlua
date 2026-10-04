--- Get one message by chat and message identifiers.
-- @module titogramlua.methods.userbot.get_message
-- @usage client:get_message(chat_id, message_id)
return function(self, chat_id, message_id)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(message_id ~= nil, 'message_id is required')
    return self:send('getMessage', {chat_id = chat_id, message_id = message_id})
end
