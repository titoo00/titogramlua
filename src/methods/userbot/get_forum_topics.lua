--- Get forum topics through TDLib getForumTopics.
-- @module titogramlua.methods.userbot.get_forum_topics
-- @usage client:get_forum_topics(params, callback)
-- @param params table with TDLib fields: chat_id:int53, query:string, offset_date:int32, offset_message_id:int53, offset_forum_topic_id:int32, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getForumTopics', {['chat_id'] = 'int53', ['query'] = 'string', ['offset_date'] = 'int32', ['offset_message_id'] = 'int53', ['offset_forum_topic_id'] = 'int32', ['limit'] = 'int32'}, nil, nil, nil)
