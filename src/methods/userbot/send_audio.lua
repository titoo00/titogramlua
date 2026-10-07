--- Send audio as the signed-in account.
-- @module titogramlua.methods.userbot.send_audio
-- @usage client:send_audio(chat_id, {['@type'] = 'inputFileLocal', path = './media'}, opts, callback)
-- @param opts media fields and send options; send_live_photo requires opts.video
local support = require('titogramlua.methods.userbot._support')
return support.media('inputMessageAudio', 'audio', 'inputAudio', {['audio'] = 'InputFile', ['album_cover_thumbnail'] = 'inputThumbnail', ['duration'] = 'int32', ['title'] = 'string', ['performer'] = 'string'}, {['audio'] = 'inputAudio', ['caption'] = 'formattedText'})
