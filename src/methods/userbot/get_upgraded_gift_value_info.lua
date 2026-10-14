--- Get upgraded gift value info through TDLib getUpgradedGiftValueInfo.
-- @module titogramlua.methods.userbot.get_upgraded_gift_value_info
-- @usage client:get_upgraded_gift_value_info(params, callback)
-- @param params table with TDLib fields: name:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getUpgradedGiftValueInfo', {['name'] = 'string'}, nil, nil, nil)
