--- Create bot through TDLib createBot.
-- @module titogramlua.methods.userbot.create_bot
-- @usage client:create_bot(params, callback)
-- @param params table with TDLib fields: manager_bot_user_id:int53, name:string, username:string, via_link:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('createBot', {['manager_bot_user_id'] = 'int53', ['name'] = 'string', ['username'] = 'string', ['via_link'] = 'Bool'}, nil, nil, nil)
