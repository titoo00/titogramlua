--- Answer guest query through TDLib answerGuestQuery.
-- @module titogramlua.methods.userbot.answer_guest_query
-- @usage client:answer_guest_query(params, callback)
-- @param params table with TDLib fields: guest_query_id:int64, result:InputInlineQueryResult
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('answerGuestQuery', {['guest_query_id'] = 'int64', ['result'] = 'InputInlineQueryResult'}, nil, nil, nil)
