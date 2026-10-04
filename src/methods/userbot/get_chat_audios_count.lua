--- Request a profile-audio page; its result reports the available total_count.
-- @module titogramlua.methods.userbot.get_chat_audios_count
-- @usage client:get_chat_audios_count(user_id)
return function(self, user_id)
    assert(user_id ~= nil, 'user_id is required')
    return self:send('getUserProfileAudios', {user_id = user_id, offset = 0, limit = 1})
end
