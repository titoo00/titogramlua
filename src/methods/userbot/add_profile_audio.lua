--- Add an audio file to the current user's profile.
-- @module titogramlua.methods.userbot.add_profile_audio
-- @usage client:add_profile_audio(audio, {title = 'Track', performer = 'Artist'})
return function(self, audio, opts)
    assert(type(audio) == 'table' and audio['@type'], 'audio must be a TDLib InputFile or inputAudio object')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    assert(audio['@type'] == 'inputAudio' or audio['@type'] == 'inputFileLocal'
        or audio['@type'] == 'inputFileRemote' or audio['@type'] == 'inputFileId',
        'audio must be inputAudio, inputFileLocal, inputFileRemote, or inputFileId')
    local input_audio = audio
    if audio['@type'] ~= 'inputAudio' then
        input_audio = {
            ['@type'] = 'inputAudio',
            audio = audio,
            album_cover_thumbnail = opts.album_cover_thumbnail,
            duration = opts.duration or 0,
            title = opts.title or '',
            performer = opts.performer or '',
        }
    end
    return self:send('addProfileAudio', {audio = input_audio})
end
