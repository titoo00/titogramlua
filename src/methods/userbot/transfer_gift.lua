--- Transfer gift through TDLib transferGift.
-- @module titogramlua.methods.userbot.transfer_gift
-- @usage client:transfer_gift(params, callback)
-- @param params table with TDLib fields: business_connection_id:string, received_gift_id:string, new_owner_id:MessageSender, star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('transferGift', {['business_connection_id'] = 'string', ['received_gift_id'] = 'string', ['new_owner_id'] = 'MessageSender', ['star_count'] = 'int53'}, nil, nil, nil)
