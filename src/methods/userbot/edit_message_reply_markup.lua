--- Edit message reply markup through TDLib editMessageReplyMarkup.
-- @module titogramlua.methods.userbot.edit_message_reply_markup
-- @usage client:edit_message_reply_markup(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, reply_markup:ReplyMarkup
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editMessageReplyMarkup', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['reply_markup'] = 'ReplyMarkup'}, nil, nil, nil)
