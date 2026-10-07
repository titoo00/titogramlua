--- Send a TDLib inputMessageRichMessage message.
-- @module titogramlua.methods.userbot.send_rich_message
-- @usage client:send_rich_message(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields message:inputRichMessage, clear_draft:Bool
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessageRichMessage', {['message'] = 'inputRichMessage', ['clear_draft'] = 'Bool'}, nil)
