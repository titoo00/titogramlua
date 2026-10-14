--- Refund star payment through TDLib refundStarPayment.
-- @module titogramlua.methods.userbot.refund_star_payment
-- @usage client:refund_star_payment(params, callback)
-- @param params table with TDLib fields: user_id:int53, telegram_payment_charge_id:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('refundStarPayment', {['user_id'] = 'int53', ['telegram_payment_charge_id'] = 'string'}, nil, nil, nil)
