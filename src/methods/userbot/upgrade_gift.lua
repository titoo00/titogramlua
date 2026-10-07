--- Upgrade gift through TDLib upgradeGift.
-- @module titogramlua.methods.userbot.upgrade_gift
-- @usage client:upgrade_gift(params, callback)
-- @param params table with TDLib fields: business_connection_id:string, received_gift_id:string, keep_original_details:Bool, star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/upgrade_gift.py
local support = require('titogramlua.methods.userbot._support')
return support.method('upgradeGift', {['business_connection_id'] = 'string', ['received_gift_id'] = 'string', ['keep_original_details'] = 'Bool', ['star_count'] = 'int53'}, nil, nil, nil)
