--- Place gift auction bid through TDLib placeGiftAuctionBid.
-- @module titogramlua.methods.userbot.place_gift_auction_bid
-- @usage client:place_gift_auction_bid(params, callback)
-- @param params table with TDLib fields: gift_id:int64, star_count:int53, user_id:int53, text:formattedText, is_private:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/place_gift_auction_bid.py
local support = require('titogramlua.methods.userbot._support')
return support.method('placeGiftAuctionBid', {['gift_id'] = 'int64', ['star_count'] = 'int53', ['user_id'] = 'int53', ['text'] = 'formattedText', ['is_private'] = 'Bool'}, nil, nil, nil)
