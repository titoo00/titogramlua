--- Create group through TDLib createNewBasicGroupChat.
-- @module titogramlua.methods.userbot.create_group
-- @usage client:create_group(params, callback)
-- @param params table with TDLib fields: user_ids:vector<int53>, title:string, message_auto_delete_time:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/create_group.py
local support = require('titogramlua.methods.userbot._support')
return support.method('createNewBasicGroupChat', {['user_ids'] = 'vector<int53>', ['title'] = 'string', ['message_auto_delete_time'] = 'int32'}, nil, nil, nil)
