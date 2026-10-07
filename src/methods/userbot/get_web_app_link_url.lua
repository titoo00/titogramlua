--- Get web app link url through TDLib getWebAppLinkUrl.
-- @module titogramlua.methods.userbot.get_web_app_link_url
-- @usage client:get_web_app_link_url(params, callback)
-- @param params table with TDLib fields: chat_id:int53, bot_user_id:int53, web_app_short_name:string, start_parameter:string, allow_write_access:Bool, parameters:webAppOpenParameters
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/get_web_app_link_url.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getWebAppLinkUrl', {['chat_id'] = 'int53', ['bot_user_id'] = 'int53', ['web_app_short_name'] = 'string', ['start_parameter'] = 'string', ['allow_write_access'] = 'Bool', ['parameters'] = 'webAppOpenParameters'}, nil, nil, nil)
