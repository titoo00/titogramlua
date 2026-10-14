--- Set bot commands through TDLib setCommands.
-- @module titogramlua.methods.userbot.set_bot_commands
-- @usage client:set_bot_commands(params, callback)
-- @param params table with TDLib fields: scope:BotCommandScope, language_code:string, commands:vector<botCommand>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setCommands', {['scope'] = 'BotCommandScope', ['language_code'] = 'string', ['commands'] = 'vector<botCommand>'}, nil, nil, nil)
