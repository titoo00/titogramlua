--- Unpin forum topic using TDLib toggleForumTopicIsPinned.
-- @module titogramlua.methods.userbot.unpin_forum_topic
-- @usage client:unpin_forum_topic(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: chat_id:int53, forum_topic_id:int32, is_pinned:Bool
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('toggleForumTopicIsPinned', {['chat_id'] = 'int53', ['forum_topic_id'] = 'int32', ['is_pinned'] = 'Bool'}, nil, {['is_pinned'] = false})
