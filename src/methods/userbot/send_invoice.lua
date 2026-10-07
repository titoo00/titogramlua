--- Send a TDLib inputMessageInvoice message.
-- @module titogramlua.methods.userbot.send_invoice
-- @usage client:send_invoice(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields invoice:invoice, title:string, description:string, photo_url:string, photo_size:int32, photo_width:int32, photo_height:int32, payload:bytes, provider_token:string, provider_data:string, start_parameter:string, paid_media:inputPaidMedia, paid_media_caption:formattedText
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessageInvoice', {['invoice'] = 'invoice', ['title'] = 'string', ['description'] = 'string', ['photo_url'] = 'string', ['photo_size'] = 'int32', ['photo_width'] = 'int32', ['photo_height'] = 'int32', ['payload'] = 'bytes', ['provider_token'] = 'string', ['provider_data'] = 'string', ['start_parameter'] = 'string', ['paid_media'] = 'inputPaidMedia', ['paid_media_caption'] = 'formattedText'}, nil)
