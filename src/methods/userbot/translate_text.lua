--- Translate text through TDLib translateText.
-- @module titogramlua.methods.userbot.translate_text
-- @usage client:translate_text(params, callback)
-- @param params table with TDLib fields: text:formattedText, to_language_code:string, tone:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/translate_text.py
local support = require('titogramlua.methods.userbot._support')
return support.method('translateText', {['text'] = 'formattedText', ['to_language_code'] = 'string', ['tone'] = 'string'}, nil, nil, nil)
