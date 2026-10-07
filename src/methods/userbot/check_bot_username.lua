--- Check bot username through TDLib checkBotUsername.
-- @module titogramlua.methods.userbot.check_bot_username
-- @usage client:check_bot_username(params, callback)
-- @param params table with TDLib fields: username:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/check_bot_username.py
local support = require('titogramlua.methods.userbot._support')
return support.method('checkBotUsername', {['username'] = 'string'}, nil, nil, nil)
