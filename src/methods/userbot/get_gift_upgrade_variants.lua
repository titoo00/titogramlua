--- Get gift upgrade variants through TDLib getUpgradedGiftVariants.
-- @module titogramlua.methods.userbot.get_gift_upgrade_variants
-- @usage client:get_gift_upgrade_variants(params, callback)
-- @param params table with TDLib fields: regular_gift_id:int64, return_upgrade_models:Bool, return_craft_models:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/get_gift_upgrade_variants.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getUpgradedGiftVariants', {['regular_gift_id'] = 'int64', ['return_upgrade_models'] = 'Bool', ['return_craft_models'] = 'Bool'}, nil, nil, nil)
