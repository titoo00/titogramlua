--- Send web page with composed TDLib requests.
-- @module titogramlua.methods.userbot.send_web_page
-- @usage client:send_web_page(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params operation options; see docs/userbot-port.md for signatures
-- @param callback optional function(result, err, client); stream_media calls it for each chunk
return require('titogramlua.methods.userbot._operations').send_web_page
