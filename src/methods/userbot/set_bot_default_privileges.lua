--- Set bot default privileges with composed TDLib requests.
-- @module titogramlua.methods.userbot.set_bot_default_privileges
-- @usage client:set_bot_default_privileges(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params operation options; see docs/userbot-port.md for signatures
-- @param callback optional function(result, err, client); stream_media calls it for each chunk
return require('titogramlua.methods.userbot._operations').set_bot_default_privileges
