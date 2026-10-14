--- Answer callback query through TDLib answerCallbackQuery.
-- @module titogramlua.methods.userbot.answer_callback_query
-- @usage client:answer_callback_query(params, callback)
-- @param params table with TDLib fields: callback_query_id:int64, text:string, show_alert:Bool, url:string, cache_time:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('answerCallbackQuery', {['callback_query_id'] = 'int64', ['text'] = 'string', ['show_alert'] = 'Bool', ['url'] = 'string', ['cache_time'] = 'int32'}, nil, nil, nil)
