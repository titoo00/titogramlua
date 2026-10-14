--- Translate text through TDLib translateText.
-- @module titogramlua.methods.userbot.translate_text
-- @usage client:translate_text(params, callback)
-- @param params table with TDLib fields: text:formattedText, to_language_code:string, tone:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('translateText', {['text'] = 'formattedText', ['to_language_code'] = 'string', ['tone'] = 'string'}, nil, nil, nil)
