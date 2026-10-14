--- Get chat member through TDLib getChatMember.
-- @module titogramlua.methods.userbot.get_chat_member
-- @usage client:get_chat_member(params, callback)
-- @param params table with TDLib fields: chat_id:int53, member_id:MessageSender
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatMember', {['chat_id'] = 'int53', ['member_id'] = 'MessageSender'}, nil, nil, nil)
