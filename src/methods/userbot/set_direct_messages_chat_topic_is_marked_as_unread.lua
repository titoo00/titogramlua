--- Set direct messages chat topic is marked as unread through TDLib setDirectMessagesChatTopicIsMarkedAsUnread.
-- @module titogramlua.methods.userbot.set_direct_messages_chat_topic_is_marked_as_unread
-- @usage client:set_direct_messages_chat_topic_is_marked_as_unread(params, callback)
-- @param params table with TDLib fields: chat_id:int53, topic_id:int53, is_marked_as_unread:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setDirectMessagesChatTopicIsMarkedAsUnread', {['chat_id'] = 'int53', ['topic_id'] = 'int53', ['is_marked_as_unread'] = 'Bool'}, nil, nil, nil)
