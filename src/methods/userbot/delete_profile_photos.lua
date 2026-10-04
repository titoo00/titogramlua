--- Delete one or more of the current user's profile photos by photo ID.
-- @module titogramlua.methods.userbot.delete_profile_photos
-- @usage client:delete_profile_photos({photo_id_1, photo_id_2})
return function(self, photo_ids)
    if type(photo_ids) == 'number' or type(photo_ids) == 'string' then
        photo_ids = {photo_ids}
    end
    assert(type(photo_ids) == 'table', 'photo_ids must be a photo ID or an array of photo IDs')
    local requests = {}
    for i, photo_id in ipairs(photo_ids) do
        assert(photo_id ~= nil, 'photo_ids cannot contain nil values')
        requests[i] = self:send('deleteProfilePhoto', {profile_photo_id = photo_id})
    end
    return requests
end
