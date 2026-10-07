--- Register a chat join request event handler.
-- @module titogramlua.methods.userbot.on_chat_join_request
-- @usage client:on_chat_join_request(callback, {group = 0, filter = function(value, client) return true end})
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @return handler token for remove_handler; callbacks receive payload, update (when present), client
return require('titogramlua.methods.userbot._events').registrar('chat_join_request')
