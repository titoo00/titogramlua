--- Sign in bot through TDLib checkAuthenticationBotToken.
-- @module titogramlua.methods.userbot.sign_in_bot
-- @usage client:sign_in_bot(params, callback)
-- @param params table with TDLib fields: token:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('checkAuthenticationBotToken', {['token'] = 'string'}, nil, nil, nil)
