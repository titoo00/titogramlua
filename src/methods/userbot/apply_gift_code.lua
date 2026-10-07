--- Apply gift code through TDLib applyPremiumGiftCode.
-- @module titogramlua.methods.userbot.apply_gift_code
-- @usage client:apply_gift_code(params, callback)
-- @param params table with TDLib fields: code:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/apply_gift_code.py
local support = require('titogramlua.methods.userbot._support')
return support.method('applyPremiumGiftCode', {['code'] = 'string'}, nil, nil, nil)
