--- Edit ephemeral message media using TDLib editEphemeralMessage.
-- @module titogramlua.methods.userbot.edit_ephemeral_message_media
-- @usage client:edit_ephemeral_message_media(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: chat_id:int53, receiver_user_id:int53, ephemeral_message_id:int32, reply_markup:ReplyMarkup, input_message_content:InputMessageContent
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('editEphemeralMessage', {['chat_id'] = 'int53', ['receiver_user_id'] = 'int53', ['ephemeral_message_id'] = 'int32', ['reply_markup'] = 'ReplyMarkup', ['input_message_content'] = 'InputMessageContent'}, nil, nil)
