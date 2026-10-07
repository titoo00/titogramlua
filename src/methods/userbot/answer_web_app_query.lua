--- Answer web app query through TDLib answerWebAppQuery.
-- @module titogramlua.methods.userbot.answer_web_app_query
-- @usage client:answer_web_app_query(params, callback)
-- @param params table with TDLib fields: web_app_query_id:string, result:InputInlineQueryResult
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/answer_web_app_query.py
local support = require('titogramlua.methods.userbot._support')
return support.method('answerWebAppQuery', {['web_app_query_id'] = 'string', ['result'] = 'InputInlineQueryResult'}, nil, nil, nil)
