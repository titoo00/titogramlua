--- Get upgraded gift through TDLib getUpgradedGift.
-- @module titogramlua.methods.userbot.get_upgraded_gift
-- @usage client:get_upgraded_gift(params, callback)
-- @param params table with TDLib fields: name:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getUpgradedGift', {['name'] = 'string'}, nil, nil, nil)
