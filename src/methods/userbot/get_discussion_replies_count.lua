--- Get discussion replies count through TDLib getMessageThread.
-- @module titogramlua.methods.userbot.get_discussion_replies_count
-- @usage client:get_discussion_replies_count(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/get_discussion_replies_count.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getMessageThread', {['chat_id'] = 'int53', ['message_id'] = 'int53'}, nil, nil, function(result) return result.reply_info and result.reply_info.reply_count or 0 end)
