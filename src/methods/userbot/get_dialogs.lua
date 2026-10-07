--- Get dialogs through TDLib getChats.
-- @module titogramlua.methods.userbot.get_dialogs
-- @usage client:get_dialogs(params, callback)
-- @param params table with TDLib fields: chat_list:ChatList, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/get_dialogs.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getChats', {['chat_list'] = 'ChatList', ['limit'] = 'int32'}, nil, nil, nil)
