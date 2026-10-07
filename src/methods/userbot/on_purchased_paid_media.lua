--- Register a purchased paid media event handler.
-- @module titogramlua.methods.userbot.on_purchased_paid_media
-- @usage client:on_purchased_paid_media(callback, {group = 0, filter = function(value, client) return true end})
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @return handler token for remove_handler; callbacks receive payload, update (when present), client
return require('titogramlua.methods.userbot._events').registrar('purchased_paid_media')
