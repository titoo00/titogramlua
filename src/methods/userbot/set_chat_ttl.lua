--- Set chat ttl through TDLib setChatMessageAutoDeleteTime.
-- @module titogramlua.methods.userbot.set_chat_ttl
-- @usage client:set_chat_ttl(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_auto_delete_time:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/set_chat_ttl.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatMessageAutoDeleteTime', {['chat_id'] = 'int53', ['message_auto_delete_time'] = 'int32'}, nil, nil, nil)
