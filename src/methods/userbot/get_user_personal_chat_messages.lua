--- Get user personal chat messages through TDLib getPersonalChatHistory.
-- @module titogramlua.methods.userbot.get_user_personal_chat_messages
-- @usage client:get_user_personal_chat_messages(params, callback)
-- @param params table with TDLib fields: user_id:int53, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/get_user_personal_chat_messages.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getPersonalChatHistory', {['user_id'] = 'int53', ['limit'] = 'int32'}, nil, nil, nil)
