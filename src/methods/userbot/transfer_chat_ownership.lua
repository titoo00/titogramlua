--- Transfer chat ownership through TDLib transferChatOwnership.
-- @module titogramlua.methods.userbot.transfer_chat_ownership
-- @usage client:transfer_chat_ownership(params, callback)
-- @param params table with TDLib fields: chat_id:int53, user_id:int53, password:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/transfer_chat_ownership.py
local support = require('titogramlua.methods.userbot._support')
return support.method('transferChatOwnership', {['chat_id'] = 'int53', ['user_id'] = 'int53', ['password'] = 'string'}, nil, nil, nil)
