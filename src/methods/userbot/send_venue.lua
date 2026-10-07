--- Send a TDLib inputMessageVenue message.
-- @module titogramlua.methods.userbot.send_venue
-- @usage client:send_venue(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields venue:venue
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessageVenue', {['venue'] = 'venue'}, nil)
