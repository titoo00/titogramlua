--- Hide general forum topic using TDLib toggleGeneralForumTopicIsHidden.
-- @module titogramlua.methods.userbot.hide_general_forum_topic
-- @usage client:hide_general_forum_topic(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: chat_id:int53, is_hidden:Bool
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('toggleGeneralForumTopicIsHidden', {['chat_id'] = 'int53', ['is_hidden'] = 'Bool'}, nil, {['is_hidden'] = true})
