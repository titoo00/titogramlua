--- Get top chats through TDLib getTopChats.
-- @module titogramlua.methods.userbot.get_top_chats
-- @usage client:get_top_chats(params, callback)
-- @param params table with TDLib fields: category:TopChatCategory, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/get_top_chats.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getTopChats', {['category'] = 'TopChatCategory', ['limit'] = 'int32'}, nil, nil, nil)
