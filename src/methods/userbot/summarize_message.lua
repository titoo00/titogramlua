--- Summarize message through TDLib summarizeMessage.
-- @module titogramlua.methods.userbot.summarize_message
-- @usage client:summarize_message(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, translate_to_language_code:string, tone:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/summarize_message.py
local support = require('titogramlua.methods.userbot._support')
return support.method('summarizeMessage', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['translate_to_language_code'] = 'string', ['tone'] = 'string'}, nil, nil, nil)
