--- Craft gift through TDLib craftGift.
-- @module titogramlua.methods.userbot.craft_gift
-- @usage client:craft_gift(params, callback)
-- @param params table with TDLib fields: received_gift_ids:vector<string>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('craftGift', {['received_gift_ids'] = 'vector<string>'}, nil, nil, nil)
