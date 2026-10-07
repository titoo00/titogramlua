--- Set chat username through TDLib setSupergroupUsername.
-- @module titogramlua.methods.userbot.set_chat_username
-- @usage client:set_chat_username(params, callback)
-- @param params table with TDLib fields: supergroup_id:int53, username:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/set_chat_username.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setSupergroupUsername', {['supergroup_id'] = 'int53', ['username'] = 'string'}, nil, nil, nil)
