--- Compose text with ai through TDLib composeTextWithAi.
-- @module titogramlua.methods.userbot.compose_text_with_ai
-- @usage client:compose_text_with_ai(params, callback)
-- @param params table with TDLib fields: text:formattedText, translate_to_language_code:string, style_name:string, add_emojis:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/compose_text_with_ai.py
local support = require('titogramlua.methods.userbot._support')
return support.method('composeTextWithAi', {['text'] = 'formattedText', ['translate_to_language_code'] = 'string', ['style_name'] = 'string', ['add_emojis'] = 'Bool'}, nil, nil, nil)
