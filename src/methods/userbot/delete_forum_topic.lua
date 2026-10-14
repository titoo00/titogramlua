--- Delete forum topic through TDLib deleteForumTopic.
-- @module titogramlua.methods.userbot.delete_forum_topic
-- @usage client:delete_forum_topic(params, callback)
-- @param params table with TDLib fields: chat_id:int53, forum_topic_id:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteForumTopic', {['chat_id'] = 'int53', ['forum_topic_id'] = 'int32'}, nil, nil, nil)
