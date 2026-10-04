--- Request profile photos or chat-photo history; read total_count from the result.
-- @module titogramlua.methods.userbot.get_chat_photos_count
-- @usage client:get_chat_photos_count(user_id) -- profile photos
-- @usage client:get_chat_photos_count(chat_id, true) -- chat-photo history
return function(self, chat_id, chat_history)
    assert(chat_id ~= nil, 'chat_id is required')
    if chat_history then
        return self:send('getChatMessageCount', {
            chat_id = chat_id,
            filter = {['@type'] = 'searchMessagesFilterChatPhoto'},
            return_local = false,
        })
    end
    return self:send('getUserProfilePhotos', {user_id = chat_id, offset = 0, limit = 1})
end
