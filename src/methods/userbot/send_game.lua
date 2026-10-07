--- Send a TDLib inputMessageGame message.
-- @module titogramlua.methods.userbot.send_game
-- @usage client:send_game(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields bot_user_id:int53, game_short_name:string
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessageGame', {['bot_user_id'] = 'int53', ['game_short_name'] = 'string'}, nil)
