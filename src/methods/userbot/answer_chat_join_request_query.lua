--- Answer chat join request query through TDLib answerChatJoinRequestQuery.
-- @module titogramlua.methods.userbot.answer_chat_join_request_query
-- @usage client:answer_chat_join_request_query(params, callback)
-- @param params table with TDLib fields: query_id:int64, result:ChatJoinRequestResult, url:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('answerChatJoinRequestQuery', {['query_id'] = 'int64', ['result'] = 'ChatJoinRequestResult', ['url'] = 'string'}, nil, nil, nil)
