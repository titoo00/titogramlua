--- Transfer chat ownership through TDLib transferChatOwnership.
-- @module titogramlua.methods.userbot.transfer_chat_ownership
-- @usage client:transfer_chat_ownership(params, callback)
-- @param params table with TDLib fields: chat_id:int53, user_id:int53, password:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('transferChatOwnership', {['chat_id'] = 'int53', ['user_id'] = 'int53', ['password'] = 'string'}, nil, nil, nil)
