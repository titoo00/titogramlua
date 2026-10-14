--- Unpin chat message through TDLib unpinChatMessage.
-- @module titogramlua.methods.userbot.unpin_chat_message
-- @usage client:unpin_chat_message(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('unpinChatMessage', {['chat_id'] = 'int53', ['message_id'] = 'int53'}, nil, nil, nil)
