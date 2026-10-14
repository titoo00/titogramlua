--- Summarize message through TDLib summarizeMessage.
-- @module titogramlua.methods.userbot.summarize_message
-- @usage client:summarize_message(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, translate_to_language_code:string, tone:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('summarizeMessage', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['translate_to_language_code'] = 'string', ['tone'] = 'string'}, nil, nil, nil)
