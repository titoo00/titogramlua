--- Get direct messages topics through TDLib loadDirectMessagesChatTopics.
-- @module titogramlua.methods.userbot.get_direct_messages_topics
-- @usage client:get_direct_messages_topics(params, callback)
-- @param params table with TDLib fields: chat_id:int53, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/get_direct_messages_topics.py
local support = require('titogramlua.methods.userbot._support')
return support.method('loadDirectMessagesChatTopics', {['chat_id'] = 'int53', ['limit'] = 'int32'}, nil, nil, nil)
