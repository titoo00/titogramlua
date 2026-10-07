--- Get payment form through TDLib getPaymentForm.
-- @module titogramlua.methods.userbot.get_payment_form
-- @usage client:get_payment_form(params, callback)
-- @param params table with TDLib fields: input_invoice:InputInvoice, theme:themeParameters
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/get_payment_form.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getPaymentForm', {['input_invoice'] = 'InputInvoice', ['theme'] = 'themeParameters'}, nil, nil, nil)
