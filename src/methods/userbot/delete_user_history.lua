--- Delete user history through TDLib deleteChatMessagesBySender.
-- @module titogramlua.methods.userbot.delete_user_history
-- @usage client:delete_user_history(params, callback)
-- @param params table with TDLib fields: chat_id:int53, sender_id:MessageSender
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/delete_user_history.py
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteChatMessagesBySender', {['chat_id'] = 'int53', ['sender_id'] = 'MessageSender'}, nil, nil, nil)
