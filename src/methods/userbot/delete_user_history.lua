--- Delete user history through TDLib deleteChatMessagesBySender.
-- @module titogramlua.methods.userbot.delete_user_history
-- @usage client:delete_user_history(params, callback)
-- @param params table with TDLib fields: chat_id:int53, sender_id:MessageSender
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteChatMessagesBySender', {['chat_id'] = 'int53', ['sender_id'] = 'MessageSender'}, nil, nil, nil)
