--- Move a profile audio track after another file, or to the beginning.
-- @module titogramlua.methods.userbot.set_profile_audio_position
-- @usage client:set_profile_audio_position(audio_id, 0)
return function(self, audio_id, after_file_id)
    assert(type(audio_id) == 'number' and audio_id > 0 and audio_id == math.floor(audio_id),
        'audio_id must be a positive integer TDLib file ID')
    assert(type(after_file_id) == 'number' and after_file_id >= 0 and after_file_id == math.floor(after_file_id),
        'after_file_id must be a non-negative integer (0 moves to the beginning)')
    return self:send('setProfileAudioPosition', {
        file_id = audio_id,
        after_file_id = after_file_id,
    })
end
