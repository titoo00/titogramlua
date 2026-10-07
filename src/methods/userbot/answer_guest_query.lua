--- Answer guest query through TDLib answerGuestQuery.
-- @module titogramlua.methods.userbot.answer_guest_query
-- @usage client:answer_guest_query(params, callback)
-- @param params table with TDLib fields: guest_query_id:int64, result:InputInlineQueryResult
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/answer_guest_query.py
local support = require('titogramlua.methods.userbot._support')
return support.method('answerGuestQuery', {['guest_query_id'] = 'int64', ['result'] = 'InputInlineQueryResult'}, nil, nil, nil)
