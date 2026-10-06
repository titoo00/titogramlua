--- Move a profile audio track to a new position.
-- @module titogramlua.methods.userbot.set_profile_audio_position
-- @usage client:set_profile_audio_position(audio_id, 0)
return function(self, audio_id, position)
    assert(type(audio_id) == 'number', 'audio_id must be a number')
    assert(type(position) == 'number' and position >= 0, 'position must be a non-negative number')
    return self:send('setProfileAudioPosition', {
        profile_audio_id = audio_id,
        new_position = math.floor(position),
    })
end
