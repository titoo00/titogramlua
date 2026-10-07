--- Approve suggested post through TDLib approveSuggestedPost.
-- @module titogramlua.methods.userbot.approve_suggested_post
-- @usage client:approve_suggested_post(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, send_date:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/approve_suggested_post.py
local support = require('titogramlua.methods.userbot._support')
return support.method('approveSuggestedPost', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['send_date'] = 'int32'}, nil, nil, nil)
