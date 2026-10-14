--- Approve suggested post through TDLib approveSuggestedPost.
-- @module titogramlua.methods.userbot.approve_suggested_post
-- @usage client:approve_suggested_post(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, send_date:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('approveSuggestedPost', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['send_date'] = 'int32'}, nil, nil, nil)
