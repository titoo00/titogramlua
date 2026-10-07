--- Decline suggested post through TDLib declineSuggestedPost.
-- @module titogramlua.methods.userbot.decline_suggested_post
-- @usage client:decline_suggested_post(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, comment:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/decline_suggested_post.py
local support = require('titogramlua.methods.userbot._support')
return support.method('declineSuggestedPost', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['comment'] = 'string'}, nil, nil, nil)
