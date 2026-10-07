--- Send chat join request web app using TDLib answerChatJoinRequestQuery.
-- @module titogramlua.methods.userbot.send_chat_join_request_web_app
-- @usage client:send_chat_join_request_web_app(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: query_id:int64, result:ChatJoinRequestResult, url:string
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('answerChatJoinRequestQuery', {['query_id'] = 'int64', ['result'] = 'ChatJoinRequestResult', ['url'] = 'string'}, nil, {['result'] = {['@type'] = 'chatJoinRequestResultQueued'}})
