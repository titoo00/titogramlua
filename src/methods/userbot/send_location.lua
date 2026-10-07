--- Send a TDLib inputMessageLocation message.
-- @module titogramlua.methods.userbot.send_location
-- @usage client:send_location(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields location:location
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessageLocation', {['location'] = 'location'}, nil)
