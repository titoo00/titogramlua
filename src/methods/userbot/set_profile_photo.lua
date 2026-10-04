--- Set the current user's profile photo using a TDLib InputChatPhoto object.
-- @module titogramlua.methods.userbot.set_profile_photo
-- @usage client:set_profile_photo({['@type'] = 'inputChatPhotoStatic', photo = {['@type'] = 'inputFileLocal', path = './profile.jpg'}})
return function(self, photo, is_public)
    assert(type(photo) == 'table' and photo['@type'], 'photo must be a TDLib InputChatPhoto object')
    return self:send('setProfilePhoto', {photo = photo, is_public = is_public == true})
end
