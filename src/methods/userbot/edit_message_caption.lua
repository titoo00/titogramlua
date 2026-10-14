--- Edit message caption through TDLib editMessageCaption.
-- @module titogramlua.methods.userbot.edit_message_caption
-- @usage client:edit_message_caption(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, reply_markup:ReplyMarkup, caption:formattedText, show_caption_above_media:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editMessageCaption', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['reply_markup'] = 'ReplyMarkup', ['caption'] = 'formattedText', ['show_caption_above_media'] = 'Bool'}, nil, nil, nil)
