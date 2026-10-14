--- Check bot username through TDLib checkBotUsername.
-- @module titogramlua.methods.userbot.check_bot_username
-- @usage client:check_bot_username(params, callback)
-- @param params table with TDLib fields: username:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('checkBotUsername', {['username'] = 'string'}, nil, nil, nil)
