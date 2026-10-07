--- Get gift auction state through TDLib getGiftAuctionState.
-- @module titogramlua.methods.userbot.get_gift_auction_state
-- @usage client:get_gift_auction_state(params, callback)
-- @param params table with TDLib fields: auction_id:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/get_gift_auction_state.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getGiftAuctionState', {['auction_id'] = 'string'}, nil, nil, nil)
