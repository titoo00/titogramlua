--- Edit ephemeral message reply markup through TDLib editEphemeralMessage.
-- @module titogramlua.methods.userbot.edit_ephemeral_message_reply_markup
-- @usage client:edit_ephemeral_message_reply_markup(params, callback)
-- @param params table with TDLib fields: chat_id:int53, receiver_user_id:int53, ephemeral_message_id:int32, reply_markup:ReplyMarkup, input_message_content:InputMessageContent
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/edit_ephemeral_message_reply_markup.py
local support = require('titogramlua.methods.userbot._support')
return support.method('editEphemeralMessage', {['chat_id'] = 'int53', ['receiver_user_id'] = 'int53', ['ephemeral_message_id'] = 'int32', ['reply_markup'] = 'ReplyMarkup', ['input_message_content'] = 'InputMessageContent'}, nil, nil, nil)
