--- Get available effects with composed TDLib requests.
-- @module titogramlua.methods.userbot.get_available_effects
-- @usage client:get_available_effects(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params operation options; see docs/userbot-port.md for signatures
-- @param callback optional function(result, err, client); stream_media calls it for each chunk
return require('titogramlua.methods.userbot._operations').get_available_effects
