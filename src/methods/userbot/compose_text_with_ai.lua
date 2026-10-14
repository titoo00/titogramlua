--- Compose text with ai through TDLib composeTextWithAi.
-- @module titogramlua.methods.userbot.compose_text_with_ai
-- @usage client:compose_text_with_ai(params, callback)
-- @param params table with TDLib fields: text:formattedText, translate_to_language_code:string, style_name:string, add_emojis:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('composeTextWithAi', {['text'] = 'formattedText', ['translate_to_language_code'] = 'string', ['style_name'] = 'string', ['add_emojis'] = 'Bool'}, nil, nil, nil)
