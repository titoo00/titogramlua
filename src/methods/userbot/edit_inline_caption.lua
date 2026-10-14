--- Edit inline caption through TDLib editInlineMessageCaption.
-- @module titogramlua.methods.userbot.edit_inline_caption
-- @usage client:edit_inline_caption(params, callback)
-- @param params table with TDLib fields: inline_message_id:string, reply_markup:ReplyMarkup, caption:formattedText, show_caption_above_media:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editInlineMessageCaption', {['inline_message_id'] = 'string', ['reply_markup'] = 'ReplyMarkup', ['caption'] = 'formattedText', ['show_caption_above_media'] = 'Bool'}, nil, nil, nil)
