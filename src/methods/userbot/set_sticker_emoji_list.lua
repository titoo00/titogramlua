--- Set sticker emoji list through TDLib setStickerEmojis.
-- @module titogramlua.methods.userbot.set_sticker_emoji_list
-- @usage client:set_sticker_emoji_list(params, callback)
-- @param params table with TDLib fields: sticker:InputFile, emojis:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setStickerEmojis', {['sticker'] = 'InputFile', ['emojis'] = 'string'}, nil, nil, nil)
