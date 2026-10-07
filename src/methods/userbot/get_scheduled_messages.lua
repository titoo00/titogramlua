--- Get scheduled messages through TDLib getChatScheduledMessages.
-- @module titogramlua.methods.userbot.get_scheduled_messages
-- @usage client:get_scheduled_messages(params, callback)
-- @param params table with TDLib fields: chat_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/get_scheduled_messages.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatScheduledMessages', {['chat_id'] = 'int53'}, nil, nil, nil)
