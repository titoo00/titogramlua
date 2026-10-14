--- Forward messages through TDLib forwardMessages.
-- @module titogramlua.methods.userbot.forward_messages
-- @usage client:forward_messages(params, callback)
-- @param params table with TDLib fields: chat_id:int53, topic_id:MessageTopic, from_chat_id:int53, message_ids:vector<int53>, options:messageSendOptions, send_copy:Bool, remove_caption:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('forwardMessages', {['chat_id'] = 'int53', ['topic_id'] = 'MessageTopic', ['from_chat_id'] = 'int53', ['message_ids'] = 'vector<int53>', ['options'] = 'messageSendOptions', ['send_copy'] = 'Bool', ['remove_caption'] = 'Bool'}, nil, nil, nil)
