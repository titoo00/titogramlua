--- Send document as the signed-in account.
-- @module titogramlua.methods.userbot.send_document
-- @usage client:send_document(chat_id, {['@type'] = 'inputFileLocal', path = './media'}, opts, callback)
-- @param opts media fields and send options; send_live_photo requires opts.video
local support = require('titogramlua.methods.userbot._support')
return support.media('inputMessageDocument', 'document', 'inputDocument', {['document'] = 'InputFile', ['thumbnail'] = 'inputThumbnail', ['disable_content_type_detection'] = 'Bool'}, {['document'] = 'inputDocument', ['caption'] = 'formattedText'})
