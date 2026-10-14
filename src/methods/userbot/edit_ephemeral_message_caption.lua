--- Edit ephemeral message caption through TDLib editEphemeralMessageCaption.
-- @module titogramlua.methods.userbot.edit_ephemeral_message_caption
-- @usage client:edit_ephemeral_message_caption(params, callback)
-- @param params table with TDLib fields: chat_id:int53, receiver_user_id:int53, ephemeral_message_id:int32, reply_markup:ReplyMarkup, caption:formattedText, show_caption_above_media:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editEphemeralMessageCaption', {['chat_id'] = 'int53', ['receiver_user_id'] = 'int53', ['ephemeral_message_id'] = 'int32', ['reply_markup'] = 'ReplyMarkup', ['caption'] = 'formattedText', ['show_caption_above_media'] = 'Bool'}, nil, nil, nil)
