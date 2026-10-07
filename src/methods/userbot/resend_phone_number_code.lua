--- Resend phone number code with composed TDLib requests.
-- @module titogramlua.methods.userbot.resend_phone_number_code
-- @usage client:resend_phone_number_code(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params operation options; see docs/userbot-port.md for signatures
-- @param callback optional function(result, err, client); stream_media calls it for each chunk
return require('titogramlua.methods.userbot._operations').resend_phone_number_code
