--- Add chat members through TDLib addChatMembers.
-- @module titogramlua.methods.userbot.add_chat_members
-- @usage client:add_chat_members(params, callback)
-- @param params table with TDLib fields: chat_id:int53, user_ids:vector<int53>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/add_chat_members.py
local support = require('titogramlua.methods.userbot._support')
return support.method('addChatMembers', {['chat_id'] = 'int53', ['user_ids'] = 'vector<int53>'}, nil, nil, nil)
