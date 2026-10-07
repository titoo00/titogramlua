--- Register a chat member updated event handler.
-- @module titogramlua.methods.userbot.on_chat_member_updated
-- @usage client:on_chat_member_updated(callback, {group = 0, filter = function(value, client) return true end})
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @return handler token for remove_handler; callbacks receive payload, update (when present), client
return require('titogramlua.methods.userbot._events').registrar('chat_member_updated')
