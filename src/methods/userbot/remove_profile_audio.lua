--- Remove an audio track from the current user's profile.
-- @module titogramlua.methods.userbot.remove_profile_audio
-- @usage client:remove_profile_audio(audio_id)
return function(self, audio_id)
    assert(type(audio_id) == 'number', 'audio_id must be a number')
    return self:send('removeProfileAudio', {profile_audio_id = audio_id})
end
