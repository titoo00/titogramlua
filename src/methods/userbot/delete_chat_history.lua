--- Delete chat history through TDLib deleteChatHistory.
-- @module titogramlua.methods.userbot.delete_chat_history
-- @usage client:delete_chat_history(params, callback)
-- @param params table with TDLib fields: chat_id:int53, remove_from_chat_list:Bool, revoke:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteChatHistory', {['chat_id'] = 'int53', ['remove_from_chat_list'] = 'Bool', ['revoke'] = 'Bool'}, nil, nil, nil)
