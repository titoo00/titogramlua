--- Get profile photos for a user, or chat-photo change messages for a group/channel.
-- @module titogramlua.methods.userbot.get_chat_photos
-- @usage client:get_chat_photos(user_id, 20) -- user profile photos
-- @usage client:get_chat_photos(chat_id, 20, true) -- chat photo history
return function(self, chat_id, limit, chat_history)
    assert(chat_id ~= nil, 'chat_id is required')
    limit = limit or 20
    assert(type(limit) == 'number' and limit > 0, 'limit must be a positive number')
    limit = math.min(math.floor(limit), 100)
    if chat_history then
        return self:send('searchChatMessages', {
            chat_id = chat_id, query = '', from_message_id = 0, limit = limit,
            filter = {['@type'] = 'searchMessagesFilterChatPhoto'},
        })
    end
    return self:send('getUserProfilePhotos', {user_id = chat_id, offset = 0, limit = limit})
end
