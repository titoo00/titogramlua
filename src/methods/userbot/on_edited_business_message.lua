--- Register a edited business message event handler.
-- @module titogramlua.methods.userbot.on_edited_business_message
-- @usage client:on_edited_business_message(callback, {group = 0, filter = function(value, client) return true end})
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @return handler token for remove_handler; callbacks receive payload, update (when present), client
return require('titogramlua.methods.userbot._events').registrar('edited_business_message')
