--- Get bot commands through TDLib getCommands.
-- @module titogramlua.methods.userbot.get_bot_commands
-- @usage client:get_bot_commands(params, callback)
-- @param params table with TDLib fields: scope:BotCommandScope, language_code:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getCommands', {['scope'] = 'BotCommandScope', ['language_code'] = 'string'}, nil, nil, nil)
