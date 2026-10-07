--- Edit message media through TDLib editMessageMedia.
-- @module titogramlua.methods.userbot.edit_message_media
-- @usage client:edit_message_media(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, reply_markup:ReplyMarkup, input_message_content:InputMessageContent
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/edit_message_media.py
local support = require('titogramlua.methods.userbot._support')
return support.method('editMessageMedia', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['reply_markup'] = 'ReplyMarkup', ['input_message_content'] = 'InputMessageContent'}, nil, nil, nil)
