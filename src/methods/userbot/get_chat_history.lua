--- Get chat history through TDLib getChatHistory.
-- @module titogramlua.methods.userbot.get_chat_history
-- @usage client:get_chat_history(params, callback)
-- @param params table with TDLib fields: chat_id:int53, from_message_id:int53, offset:int32, limit:int32, only_local:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/get_chat_history.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatHistory', {['chat_id'] = 'int53', ['from_message_id'] = 'int53', ['offset'] = 'int32', ['limit'] = 'int32', ['only_local'] = 'Bool'}, nil, nil, nil)
