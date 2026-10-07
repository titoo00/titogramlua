--- Send voice as the signed-in account.
-- @module titogramlua.methods.userbot.send_voice
-- @usage client:send_voice(chat_id, {['@type'] = 'inputFileLocal', path = './media'}, opts, callback)
-- @param opts media fields and send options; send_live_photo requires opts.video
local support = require('titogramlua.methods.userbot._support')
return support.media('inputMessageVoiceNote', 'voice_note', 'inputVoiceNote', {['voice_note'] = 'InputFile', ['duration'] = 'int32', ['waveform'] = 'bytes'}, {['voice_note'] = 'inputVoiceNote', ['caption'] = 'formattedText', ['self_destruct_type'] = 'MessageSelfDestructType'})
