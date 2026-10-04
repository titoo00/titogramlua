--- Get groups shared with another user.
-- @module titogramlua.methods.userbot.get_common_chats
-- @usage client:get_common_chats(user_id, 0, 50)
return function(self, user_id, offset_chat_id, limit)
    assert(user_id ~= nil, 'user_id is required')
    offset_chat_id = offset_chat_id or 0
    limit = limit or 100
    assert(type(limit) == 'number' and limit > 0, 'limit must be a positive number')
    return self:send('getGroupsInCommon', {
        user_id = user_id, offset_chat_id = offset_chat_id, limit = math.min(math.floor(limit), 100),
    })
end
