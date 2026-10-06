--- Add an audio file to the current user's profile.
-- @module titogramlua.methods.userbot.add_profile_audio
-- @usage client:add_profile_audio(audio, {title = 'Track', performer = 'Artist'})
return function(self, audio, opts)
    assert(type(audio) == 'table' and audio['@type'], 'audio must be a TDLib InputFile object')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    return self:send('addProfileAudio', {
        audio = audio,
        title = opts.title or '',
        performer = opts.performer or '',
    })
end
