--- Unpin all forum topic messages through TDLib unpinAllForumTopicMessages.
-- @module titogramlua.methods.userbot.unpin_all_forum_topic_messages
-- @usage client:unpin_all_forum_topic_messages(params, callback)
-- @param params table with TDLib fields: chat_id:int53, forum_topic_id:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/unpin_all_forum_topic_messages.py
local support = require('titogramlua.methods.userbot._support')
return support.method('unpinAllForumTopicMessages', {['chat_id'] = 'int53', ['forum_topic_id'] = 'int32'}, nil, nil, nil)
