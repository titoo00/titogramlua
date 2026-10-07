--- Edit message reply markup through TDLib editMessageReplyMarkup.
-- @module titogramlua.methods.userbot.edit_message_reply_markup
-- @usage client:edit_message_reply_markup(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, reply_markup:ReplyMarkup
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/edit_message_reply_markup.py
local support = require('titogramlua.methods.userbot._support')
return support.method('editMessageReplyMarkup', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['reply_markup'] = 'ReplyMarkup'}, nil, nil, nil)
