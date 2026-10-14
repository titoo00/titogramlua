--- Get managed bot token through TDLib getManagedBotToken.
-- @module titogramlua.methods.userbot.get_managed_bot_token
-- @usage client:get_managed_bot_token(params, callback)
-- @param params table with TDLib fields: bot_user_id:int53, revoke:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getManagedBotToken', {['bot_user_id'] = 'int53', ['revoke'] = 'Bool'}, {['revoke'] = false}, nil, nil)
