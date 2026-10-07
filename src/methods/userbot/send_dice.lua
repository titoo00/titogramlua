--- Send a TDLib inputMessageDice message.
-- @module titogramlua.methods.userbot.send_dice
-- @usage client:send_dice(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields emoji:string, clear_draft:Bool
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessageDice', {['emoji'] = 'string', ['clear_draft'] = 'Bool'}, {['emoji'] = '🎲', ['clear_draft'] = false})
