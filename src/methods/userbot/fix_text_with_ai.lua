--- Fix text with ai through TDLib fixTextWithAi.
-- @module titogramlua.methods.userbot.fix_text_with_ai
-- @usage client:fix_text_with_ai(params, callback)
-- @param params table with TDLib fields: text:formattedText
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/fix_text_with_ai.py
local support = require('titogramlua.methods.userbot._support')
return support.method('fixTextWithAi', {['text'] = 'formattedText'}, nil, nil, nil)
