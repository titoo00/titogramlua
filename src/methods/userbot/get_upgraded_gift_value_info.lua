--- Get upgraded gift value info through TDLib getUpgradedGiftValueInfo.
-- @module titogramlua.methods.userbot.get_upgraded_gift_value_info
-- @usage client:get_upgraded_gift_value_info(params, callback)
-- @param params table with TDLib fields: name:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/get_upgraded_gift_value_info.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getUpgradedGiftValueInfo', {['name'] = 'string'}, nil, nil, nil)
