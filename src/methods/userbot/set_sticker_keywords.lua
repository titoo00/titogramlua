--- Set sticker keywords through TDLib setStickerKeywords.
-- @module titogramlua.methods.userbot.set_sticker_keywords
-- @usage client:set_sticker_keywords(params, callback)
-- @param params table with TDLib fields: sticker:InputFile, keywords:vector<string>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setStickerKeywords', {['sticker'] = 'InputFile', ['keywords'] = 'vector<string>'}, nil, nil, nil)
