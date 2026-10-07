--- Send sticker as the signed-in account.
-- @module titogramlua.methods.userbot.send_sticker
-- @usage client:send_sticker(chat_id, {['@type'] = 'inputFileLocal', path = './media'}, opts, callback)
-- @param opts media fields and send options; send_live_photo requires opts.video
local support = require('titogramlua.methods.userbot._support')
return support.media('inputMessageSticker', 'sticker', 'inputSticker', {['sticker'] = 'InputFile', ['thumbnail'] = 'inputThumbnail', ['width'] = 'int32', ['height'] = 'int32'}, {['sticker'] = 'inputSticker', ['emoji'] = 'string'})
