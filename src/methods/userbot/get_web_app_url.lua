--- Get web app url through TDLib getWebAppUrl.
-- @module titogramlua.methods.userbot.get_web_app_url
-- @usage client:get_web_app_url(params, callback)
-- @param params table with TDLib fields: bot_user_id:int53, url:string, parameters:webAppOpenParameters
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getWebAppUrl', {['bot_user_id'] = 'int53', ['url'] = 'string', ['parameters'] = 'webAppOpenParameters'}, nil, nil, nil)
