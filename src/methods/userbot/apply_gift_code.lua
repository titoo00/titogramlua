--- Apply gift code through TDLib applyPremiumGiftCode.
-- @module titogramlua.methods.userbot.apply_gift_code
-- @usage client:apply_gift_code(params, callback)
-- @param params table with TDLib fields: code:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('applyPremiumGiftCode', {['code'] = 'string'}, nil, nil, nil)
