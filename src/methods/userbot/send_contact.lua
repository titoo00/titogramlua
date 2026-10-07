--- Send a TDLib inputMessageContact message.
-- @module titogramlua.methods.userbot.send_contact
-- @usage client:send_contact(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields contact:contact
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessageContact', {['contact'] = 'contact'}, nil)
