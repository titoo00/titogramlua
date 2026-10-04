--- Get a chat by its TDLib chat identifier.
-- @module titogramlua.methods.userbot.get_chat
-- @usage client:get_chat(chat_id)
return function(self, chat_id)
    assert(chat_id ~= nil, 'chat_id is required')
    return self:send('getChat', {chat_id = chat_id})
end
