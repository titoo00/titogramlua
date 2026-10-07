--- Replace managed bot token through TDLib getManagedBotToken.
-- @module titogramlua.methods.userbot.replace_managed_bot_token
-- @usage client:replace_managed_bot_token(params, callback)
-- @param params table with TDLib fields: bot_user_id:int53, revoke:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/replace_managed_bot_token.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getManagedBotToken', {['bot_user_id'] = 'int53', ['revoke'] = 'Bool'}, {['revoke'] = true}, {['revoke'] = true}, nil)
