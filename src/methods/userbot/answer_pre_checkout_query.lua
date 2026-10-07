--- Answer pre checkout query through TDLib answerPreCheckoutQuery.
-- @module titogramlua.methods.userbot.answer_pre_checkout_query
-- @usage client:answer_pre_checkout_query(params, callback)
-- @param params table with TDLib fields: pre_checkout_query_id:int64, error_message:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/answer_pre_checkout_query.py
local support = require('titogramlua.methods.userbot._support')
return support.method('answerPreCheckoutQuery', {['pre_checkout_query_id'] = 'int64', ['error_message'] = 'string'}, nil, nil, nil)
