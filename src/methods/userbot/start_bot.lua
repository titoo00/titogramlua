--- Start bot through TDLib sendBotStartMessage.
-- @module titogramlua.methods.userbot.start_bot
-- @usage client:start_bot(params, callback)
-- @param params table with TDLib fields: bot_user_id:int53, chat_id:int53, parameter:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/start_bot.py
local support = require('titogramlua.methods.userbot._support')
return support.method('sendBotStartMessage', {['bot_user_id'] = 'int53', ['chat_id'] = 'int53', ['parameter'] = 'string'}, nil, nil, nil)
