--- Set send as chat through TDLib setChatMessageSender.
-- @module titogramlua.methods.userbot.set_send_as_chat
-- @usage client:set_send_as_chat(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_sender_id:MessageSender
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatMessageSender', {['chat_id'] = 'int53', ['message_sender_id'] = 'MessageSender'}, nil, nil, nil)
