--- Send a TDLib inputMessagePaidMedia message.
-- @module titogramlua.methods.userbot.send_paid_media
-- @usage client:send_paid_media(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields star_count:int53, paid_media:vector<inputPaidMedia>, caption:formattedText, show_caption_above_media:Bool, payload:string
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessagePaidMedia', {['star_count'] = 'int53', ['paid_media'] = 'vector<inputPaidMedia>', ['caption'] = 'formattedText', ['show_caption_above_media'] = 'Bool', ['payload'] = 'string'}, nil)
