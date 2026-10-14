--- Answer inline query through TDLib answerInlineQuery.
-- @module titogramlua.methods.userbot.answer_inline_query
-- @usage client:answer_inline_query(params, callback)
-- @param params table with TDLib fields: inline_query_id:int64, is_personal:Bool, button:inlineQueryResultsButton, results:vector<InputInlineQueryResult>, cache_time:int32, next_offset:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('answerInlineQuery', {['inline_query_id'] = 'int64', ['is_personal'] = 'Bool', ['button'] = 'inlineQueryResultsButton', ['results'] = 'vector<InputInlineQueryResult>', ['cache_time'] = 'int32', ['next_offset'] = 'string'}, nil, nil, nil)
