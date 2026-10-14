--- Translate message text through TDLib translateMessageText.
-- @module titogramlua.methods.userbot.translate_message_text
-- @usage client:translate_message_text(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, to_language_code:string, tone:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('translateMessageText', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['to_language_code'] = 'string', ['tone'] = 'string'}, nil, nil, nil)
