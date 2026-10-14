--- Stop poll through TDLib stopPoll.
-- @module titogramlua.methods.userbot.stop_poll
-- @usage client:stop_poll(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, reply_markup:ReplyMarkup
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('stopPoll', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['reply_markup'] = 'ReplyMarkup'}, nil, nil, nil)
