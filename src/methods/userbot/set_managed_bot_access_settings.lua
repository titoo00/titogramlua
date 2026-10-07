--- Set managed bot access settings through TDLib setManagedBotAccessSettings.
-- @module titogramlua.methods.userbot.set_managed_bot_access_settings
-- @usage client:set_managed_bot_access_settings(params, callback)
-- @param params table with TDLib fields: bot_user_id:int53, settings:botAccessSettings
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/set_managed_bot_access_settings.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setManagedBotAccessSettings', {['bot_user_id'] = 'int53', ['settings'] = 'botAccessSettings'}, nil, nil, nil)
