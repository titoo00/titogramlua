--- Send video as the signed-in account.
-- @module titogramlua.methods.userbot.send_video
-- @usage client:send_video(chat_id, {['@type'] = 'inputFileLocal', path = './media'}, opts, callback)
-- @param opts media fields and send options; send_live_photo requires opts.video
local support = require('titogramlua.methods.userbot._support')
return support.media('inputMessageVideo', 'video', 'inputVideo', {['video'] = 'InputFile', ['thumbnail'] = 'inputThumbnail', ['cover'] = 'InputFile', ['start_timestamp'] = 'int32', ['added_sticker_file_ids'] = 'vector<int32>', ['duration'] = 'int32', ['width'] = 'int32', ['height'] = 'int32', ['supports_streaming'] = 'Bool'}, {['video'] = 'inputVideo', ['caption'] = 'formattedText', ['show_caption_above_media'] = 'Bool', ['self_destruct_type'] = 'MessageSelfDestructType', ['has_spoiler'] = 'Bool'})
