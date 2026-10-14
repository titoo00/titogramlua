--- Edit inline reply markup through TDLib editInlineMessageReplyMarkup.
-- @module titogramlua.methods.userbot.edit_inline_reply_markup
-- @usage client:edit_inline_reply_markup(params, callback)
-- @param params table with TDLib fields: inline_message_id:string, reply_markup:ReplyMarkup
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editInlineMessageReplyMarkup', {['inline_message_id'] = 'string', ['reply_markup'] = 'ReplyMarkup'}, nil, nil, nil)
