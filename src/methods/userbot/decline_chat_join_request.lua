--- Decline chat join request through TDLib processChatJoinRequest.
-- @module titogramlua.methods.userbot.decline_chat_join_request
-- @usage client:decline_chat_join_request(params, callback)
-- @param params table with TDLib fields: chat_id:int53, user_id:int53, approve:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/invite_links/decline_chat_join_request.py
local support = require('titogramlua.methods.userbot._support')
return support.method('processChatJoinRequest', {['chat_id'] = 'int53', ['user_id'] = 'int53', ['approve'] = 'Bool'}, nil, {['approve'] = false}, nil)
