--- Delete direct messages chat topic history through TDLib deleteDirectMessagesChatTopicHistory.
-- @module titogramlua.methods.userbot.delete_direct_messages_chat_topic_history
-- @usage client:delete_direct_messages_chat_topic_history(params, callback)
-- @param params table with TDLib fields: chat_id:int53, topic_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteDirectMessagesChatTopicHistory', {['chat_id'] = 'int53', ['topic_id'] = 'int53'}, nil, nil, nil)
