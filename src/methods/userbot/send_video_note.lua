--- Send video note as the signed-in account.
-- @module titogramlua.methods.userbot.send_video_note
-- @usage client:send_video_note(chat_id, {['@type'] = 'inputFileLocal', path = './media'}, opts, callback)
-- @param opts media fields and send options; send_live_photo requires opts.video
local support = require('titogramlua.methods.userbot._support')
return support.media('inputMessageVideoNote', 'video_note', 'inputVideoNote', {['video_note'] = 'InputFile', ['thumbnail'] = 'inputThumbnail', ['duration'] = 'int32', ['length'] = 'int32'}, {['video_note'] = 'inputVideoNote', ['self_destruct_type'] = 'MessageSelfDestructType'})
