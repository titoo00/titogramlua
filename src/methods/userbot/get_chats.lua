--- List chats from a TDLib chat list.
-- @module titogramlua.methods.userbot.get_chats
-- @usage client:get_chats(nil, 50) -- first 50 chats in the main list
return function(self, chat_list, limit)
    assert(type(limit) == 'number' and limit > 0, 'limit must be a positive number')
    return self:send('getChats', {chat_list = chat_list, limit = math.floor(limit)})
end
