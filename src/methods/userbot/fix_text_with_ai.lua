--- Fix text with ai through TDLib fixTextWithAi.
-- @module titogramlua.methods.userbot.fix_text_with_ai
-- @usage client:fix_text_with_ai(params, callback)
-- @param params table with TDLib fields: text:formattedText
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('fixTextWithAi', {['text'] = 'formattedText'}, nil, nil, nil)
