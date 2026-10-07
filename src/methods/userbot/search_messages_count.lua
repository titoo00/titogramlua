--- Search messages count through TDLib searchChatMessages.
-- @module titogramlua.methods.userbot.search_messages_count
-- @usage client:search_messages_count(params, callback)
-- @param params table with TDLib fields: chat_id:int53, topic_id:MessageTopic, query:string, sender_id:MessageSender, from_message_id:int53, offset:int32, limit:int32, filter:SearchMessagesFilter
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/search_messages_count.py
local support = require('titogramlua.methods.userbot._support')
return support.method('searchChatMessages', {['chat_id'] = 'int53', ['topic_id'] = 'MessageTopic', ['query'] = 'string', ['sender_id'] = 'MessageSender', ['from_message_id'] = 'int53', ['offset'] = 'int32', ['limit'] = 'int32', ['filter'] = 'SearchMessagesFilter'}, {['from_message_id'] = 0, ['offset'] = 0, ['limit'] = 1}, nil, function(result) return result.total_count end)
