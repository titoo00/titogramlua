--- Get chat members through TDLib searchChatMembers.
-- @module titogramlua.methods.userbot.get_chat_members
-- @usage client:get_chat_members(params, callback)
-- @param params table with TDLib fields: chat_id:int53, query:string, limit:int32, filter:ChatMembersFilter
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('searchChatMembers', {['chat_id'] = 'int53', ['query'] = 'string', ['limit'] = 'int32', ['filter'] = 'ChatMembersFilter'}, nil, nil, nil)
