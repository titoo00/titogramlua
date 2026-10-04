--- Check whether a username can be assigned to an eligible chat.
-- @module titogramlua.methods.userbot.check_username
-- @usage client:check_username(chat_id, 'public_name')
return function(self, chat_id, username)
    assert(chat_id ~= nil, 'chat_id is required (use 0 for a chat being created)')
    assert(type(username) == 'string' and username ~= '', 'username must be a non-empty string')
    return self:send('checkChatUsername', {chat_id = chat_id, username = username})
end
