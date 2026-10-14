--- Get boosts through TDLib getAvailableChatBoostSlots.
-- @module titogramlua.methods.userbot.get_boosts
-- @usage client:get_boosts(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getAvailableChatBoostSlots', {}, nil, nil, nil)
