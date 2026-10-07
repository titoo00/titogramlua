--- Get chat join requests through TDLib getChatJoinRequests.
-- @module titogramlua.methods.userbot.get_chat_join_requests
-- @usage client:get_chat_join_requests(params, callback)
-- @param params table with TDLib fields: chat_id:int53, invite_link:string, query:string, offset_request:chatJoinRequest, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/invite_links/get_chat_join_requests.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatJoinRequests', {['chat_id'] = 'int53', ['invite_link'] = 'string', ['query'] = 'string', ['offset_request'] = 'chatJoinRequest', ['limit'] = 'int32'}, nil, nil, nil)
