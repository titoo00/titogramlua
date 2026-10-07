--- Create invoice link through TDLib createInvoiceLink.
-- @module titogramlua.methods.userbot.create_invoice_link
-- @usage client:create_invoice_link(params, callback)
-- @param params table with TDLib fields: business_connection_id:string, invoice:InputMessageContent
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/create_invoice_link.py
local support = require('titogramlua.methods.userbot._support')
return support.method('createInvoiceLink', {['business_connection_id'] = 'string', ['invoice'] = 'InputMessageContent'}, nil, nil, nil)
