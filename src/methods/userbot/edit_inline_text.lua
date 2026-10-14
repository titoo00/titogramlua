--- Edit inline text through TDLib editInlineMessageText.
-- @module titogramlua.methods.userbot.edit_inline_text
-- @usage client:edit_inline_text(params, callback)
-- @param params table with TDLib fields: inline_message_id:string, reply_markup:ReplyMarkup, input_message_content:InputMessageContent
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editInlineMessageText', {['inline_message_id'] = 'string', ['reply_markup'] = 'ReplyMarkup', ['input_message_content'] = 'InputMessageContent'}, nil, nil, nil)
