--- Send gift purchase offer through TDLib sendGiftPurchaseOffer.
-- @module titogramlua.methods.userbot.send_gift_purchase_offer
-- @usage client:send_gift_purchase_offer(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender, gift_name:string, price:GiftResalePrice, duration:int32, paid_message_star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/send_gift_purchase_offer.py
local support = require('titogramlua.methods.userbot._support')
return support.method('sendGiftPurchaseOffer', {['owner_id'] = 'MessageSender', ['gift_name'] = 'string', ['price'] = 'GiftResalePrice', ['duration'] = 'int32', ['paid_message_star_count'] = 'int53'}, nil, nil, nil)
