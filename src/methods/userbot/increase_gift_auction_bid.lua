--- Increase gift auction bid through TDLib increaseGiftAuctionBid.
-- @module titogramlua.methods.userbot.increase_gift_auction_bid
-- @usage client:increase_gift_auction_bid(params, callback)
-- @param params table with TDLib fields: gift_id:int64, star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('increaseGiftAuctionBid', {['gift_id'] = 'int64', ['star_count'] = 'int53'}, nil, nil, nil)
