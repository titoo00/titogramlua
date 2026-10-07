--- Edit inline reply markup through TDLib editInlineMessageReplyMarkup.
-- @module titogramlua.methods.userbot.edit_inline_reply_markup
-- @usage client:edit_inline_reply_markup(params, callback)
-- @param params table with TDLib fields: inline_message_id:string, reply_markup:ReplyMarkup
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/edit_inline_reply_markup.py
local support = require('titogramlua.methods.userbot._support')
return support.method('editInlineMessageReplyMarkup', {['inline_message_id'] = 'string', ['reply_markup'] = 'ReplyMarkup'}, nil, nil, nil)
