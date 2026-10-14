--- Get owned bots through TDLib getOwnedBots.
-- @module titogramlua.methods.userbot.get_owned_bots
-- @usage client:get_owned_bots(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getOwnedBots', {}, nil, nil, nil)
