--- Remove handler with composed TDLib requests.
-- @module titogramlua.methods.userbot.remove_handler
-- @usage client:remove_handler(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params operation options; see docs/userbot-port.md for signatures
-- @param callback optional function(result, err, client); stream_media calls it for each chunk
return require('titogramlua.methods.userbot._operations').remove_handler
