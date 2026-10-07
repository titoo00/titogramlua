--- Stop poll through TDLib stopPoll.
-- @module titogramlua.methods.userbot.stop_poll
-- @usage client:stop_poll(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, reply_markup:ReplyMarkup
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/stop_poll.py
local support = require('titogramlua.methods.userbot._support')
return support.method('stopPoll', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['reply_markup'] = 'ReplyMarkup'}, nil, nil, nil)
