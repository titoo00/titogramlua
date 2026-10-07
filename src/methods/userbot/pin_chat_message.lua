--- Pin chat message through TDLib pinChatMessage.
-- @module titogramlua.methods.userbot.pin_chat_message
-- @usage client:pin_chat_message(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, disable_notification:Bool, only_for_self:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/pin_chat_message.py
local support = require('titogramlua.methods.userbot._support')
return support.method('pinChatMessage', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['disable_notification'] = 'Bool', ['only_for_self'] = 'Bool'}, nil, nil, nil)
