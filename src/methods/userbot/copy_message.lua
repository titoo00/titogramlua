--- Copy message through TDLib forwardMessages.
-- @module titogramlua.methods.userbot.copy_message
-- @usage client:copy_message(params, callback)
-- @param params table with TDLib fields: chat_id:int53, topic_id:MessageTopic, from_chat_id:int53, message_ids:vector<int53>, options:messageSendOptions, send_copy:Bool, remove_caption:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/copy_message.py
local support = require('titogramlua.methods.userbot._support')
return support.method('forwardMessages', {['chat_id'] = 'int53', ['topic_id'] = 'MessageTopic', ['from_chat_id'] = 'int53', ['message_ids'] = 'vector<int53>', ['options'] = 'messageSendOptions', ['send_copy'] = 'Bool', ['remove_caption'] = 'Bool'}, nil, {['send_copy'] = true}, nil)
