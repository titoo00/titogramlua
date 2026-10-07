--- Set gift resale price through TDLib setGiftResalePrice.
-- @module titogramlua.methods.userbot.set_gift_resale_price
-- @usage client:set_gift_resale_price(params, callback)
-- @param params table with TDLib fields: received_gift_id:string, price:GiftResalePrice
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/set_gift_resale_price.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setGiftResalePrice', {['received_gift_id'] = 'string', ['price'] = 'GiftResalePrice'}, nil, nil, nil)
