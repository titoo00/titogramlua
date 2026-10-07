--- Process gift purchase offer through TDLib processGiftPurchaseOffer.
-- @module titogramlua.methods.userbot.process_gift_purchase_offer
-- @usage client:process_gift_purchase_offer(params, callback)
-- @param params table with TDLib fields: message_id:int53, accept:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/process_gift_purchase_offer.py
local support = require('titogramlua.methods.userbot._support')
return support.method('processGiftPurchaseOffer', {['message_id'] = 'int53', ['accept'] = 'Bool'}, nil, nil, nil)
