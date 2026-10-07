--- Send live photo as the signed-in account.
-- @module titogramlua.methods.userbot.send_live_photo
-- @usage client:send_live_photo(chat_id, {['@type'] = 'inputFileLocal', path = './media'}, opts, callback)
-- @param opts media fields and send options; send_live_photo requires opts.video
local support = require('titogramlua.methods.userbot._support')
return support.media('inputMessagePhoto', 'photo', 'inputPhoto', {['photo'] = 'InputFile', ['thumbnail'] = 'inputThumbnail', ['video'] = 'InputFile', ['added_sticker_file_ids'] = 'vector<int32>', ['width'] = 'int32', ['height'] = 'int32'}, {['photo'] = 'inputPhoto', ['caption'] = 'formattedText', ['show_caption_above_media'] = 'Bool', ['self_destruct_type'] = 'MessageSelfDestructType', ['has_spoiler'] = 'Bool'})
