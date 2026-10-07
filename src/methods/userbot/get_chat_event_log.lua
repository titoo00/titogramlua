--- Get chat event log through TDLib getChatEventLog.
-- @module titogramlua.methods.userbot.get_chat_event_log
-- @usage client:get_chat_event_log(params, callback)
-- @param params table with TDLib fields: chat_id:int53, query:string, from_event_id:int64, limit:int32, filters:chatEventLogFilters, user_ids:vector<int53>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/get_chat_event_log.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatEventLog', {['chat_id'] = 'int53', ['query'] = 'string', ['from_event_id'] = 'int64', ['limit'] = 'int32', ['filters'] = 'chatEventLogFilters', ['user_ids'] = 'vector<int53>'}, nil, nil, nil)
