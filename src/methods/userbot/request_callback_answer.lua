--- Request callback answer through TDLib getCallbackQueryAnswer.
-- @module titogramlua.methods.userbot.request_callback_answer
-- @usage client:request_callback_answer(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, payload:CallbackQueryPayload
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/request_callback_answer.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getCallbackQueryAnswer', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['payload'] = 'CallbackQueryPayload'}, nil, nil, nil)
