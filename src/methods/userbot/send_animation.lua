--- Send animation as the signed-in account.
-- @module titogramlua.methods.userbot.send_animation
-- @usage client:send_animation(chat_id, {['@type'] = 'inputFileLocal', path = './media'}, opts, callback)
-- @param opts media fields and send options; send_live_photo requires opts.video
local support = require('titogramlua.methods.userbot._support')
return support.media('inputMessageAnimation', 'animation', 'inputAnimation', {['animation'] = 'InputFile', ['thumbnail'] = 'inputThumbnail', ['added_sticker_file_ids'] = 'vector<int32>', ['duration'] = 'int32', ['width'] = 'int32', ['height'] = 'int32'}, {['animation'] = 'inputAnimation', ['caption'] = 'formattedText', ['show_caption_above_media'] = 'Bool', ['has_spoiler'] = 'Bool'})
