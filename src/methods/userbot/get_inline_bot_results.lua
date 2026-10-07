--- Get inline bot results through TDLib getInlineQueryResults.
-- @module titogramlua.methods.userbot.get_inline_bot_results
-- @usage client:get_inline_bot_results(params, callback)
-- @param params table with TDLib fields: bot_user_id:int53, chat_id:int53, user_location:location, query:string, offset:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/get_inline_bot_results.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getInlineQueryResults', {['bot_user_id'] = 'int53', ['chat_id'] = 'int53', ['user_location'] = 'location', ['query'] = 'string', ['offset'] = 'string'}, {['offset'] = '', ['query'] = ''}, nil, nil)
