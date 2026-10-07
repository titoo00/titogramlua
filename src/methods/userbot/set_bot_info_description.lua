--- Set bot info description through TDLib setBotInfoDescription.
-- @module titogramlua.methods.userbot.set_bot_info_description
-- @usage client:set_bot_info_description(params, callback)
-- @param params table with TDLib fields: bot_user_id:int53, language_code:string, description:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/set_bot_info_description.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setBotInfoDescription', {['bot_user_id'] = 'int53', ['language_code'] = 'string', ['description'] = 'string'}, nil, nil, nil)
