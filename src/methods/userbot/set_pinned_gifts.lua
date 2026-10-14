--- Set pinned gifts through TDLib setPinnedGifts.
-- @module titogramlua.methods.userbot.set_pinned_gifts
-- @usage client:set_pinned_gifts(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender, received_gift_ids:vector<string>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setPinnedGifts', {['owner_id'] = 'MessageSender', ['received_gift_ids'] = 'vector<string>'}, nil, nil, nil)
