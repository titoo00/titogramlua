--- Remove an audio track from the current user's profile.
-- @module titogramlua.methods.userbot.remove_profile_audio
-- @usage client:remove_profile_audio(audio_id)
return function(self, audio_id)
    assert(type(audio_id) == 'number' and audio_id > 0 and audio_id == math.floor(audio_id),
        'audio_id must be a positive integer TDLib file ID')
    return self:send('removeProfileAudio', {file_id = audio_id})
end
