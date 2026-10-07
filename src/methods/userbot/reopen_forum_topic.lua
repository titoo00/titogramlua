--- Reopen forum topic using TDLib toggleForumTopicIsClosed.
-- @module titogramlua.methods.userbot.reopen_forum_topic
-- @usage client:reopen_forum_topic(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: chat_id:int53, forum_topic_id:int32, is_closed:Bool
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('toggleForumTopicIsClosed', {['chat_id'] = 'int53', ['forum_topic_id'] = 'int32', ['is_closed'] = 'Bool'}, nil, {['is_closed'] = false})
