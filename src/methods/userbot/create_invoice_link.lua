--- Create invoice link through TDLib createInvoiceLink.
-- @module titogramlua.methods.userbot.create_invoice_link
-- @usage client:create_invoice_link(params, callback)
-- @param params table with TDLib fields: business_connection_id:string, invoice:InputMessageContent
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('createInvoiceLink', {['business_connection_id'] = 'string', ['invoice'] = 'InputMessageContent'}, nil, nil, nil)
