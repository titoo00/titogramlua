--- Send payment form through TDLib sendPaymentForm.
-- @module titogramlua.methods.userbot.send_payment_form
-- @usage client:send_payment_form(params, callback)
-- @param params table with TDLib fields: input_invoice:InputInvoice, payment_form_id:int64, order_info_id:string, shipping_option_id:string, credentials:InputCredentials, tip_amount:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/send_payment_form.py
local support = require('titogramlua.methods.userbot._support')
return support.method('sendPaymentForm', {['input_invoice'] = 'InputInvoice', ['payment_form_id'] = 'int64', ['order_info_id'] = 'string', ['shipping_option_id'] = 'string', ['credentials'] = 'InputCredentials', ['tip_amount'] = 'int53'}, nil, nil, nil)
