--- Get main web app through TDLib getMainWebApp.
-- @module titogramlua.methods.userbot.get_main_web_app
-- @usage client:get_main_web_app(params, callback)
-- @param params table with TDLib fields: chat_id:int53, bot_user_id:int53, start_parameter:string, parameters:webAppOpenParameters
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/get_main_web_app.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getMainWebApp', {['chat_id'] = 'int53', ['bot_user_id'] = 'int53', ['start_parameter'] = 'string', ['parameters'] = 'webAppOpenParameters'}, nil, nil, nil)
