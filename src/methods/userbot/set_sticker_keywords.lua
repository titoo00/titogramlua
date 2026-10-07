--- Set sticker keywords through TDLib setStickerKeywords.
-- @module titogramlua.methods.userbot.set_sticker_keywords
-- @usage client:set_sticker_keywords(params, callback)
-- @param params table with TDLib fields: sticker:InputFile, keywords:vector<string>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/set_sticker_keywords.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setStickerKeywords', {['sticker'] = 'InputFile', ['keywords'] = 'vector<string>'}, nil, nil, nil)
