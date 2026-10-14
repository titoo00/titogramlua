--- Buy gift upgrade through TDLib buyGiftUpgrade.
-- @module titogramlua.methods.userbot.buy_gift_upgrade
-- @usage client:buy_gift_upgrade(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender, prepaid_upgrade_hash:string, star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('buyGiftUpgrade', {['owner_id'] = 'MessageSender', ['prepaid_upgrade_hash'] = 'string', ['star_count'] = 'int53'}, nil, nil, nil)
