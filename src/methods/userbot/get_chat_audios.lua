--- Get profile audio tracks for a user (TDLib's user profile audio list).
-- @module titogramlua.methods.userbot.get_chat_audios
-- @usage client:get_chat_audios(user_id, 0, 20)
return function(self, user_id, offset, limit)
    assert(user_id ~= nil, 'user_id is required')
    offset = offset or 0
    limit = limit or 20
    assert(type(offset) == 'number' and offset >= 0, 'offset must be a non-negative number')
    assert(type(limit) == 'number' and limit > 0, 'limit must be a positive number')
    return self:send('getUserProfileAudios', {
        user_id = user_id, offset = math.floor(offset), limit = math.min(math.floor(limit), 100),
    })
end
