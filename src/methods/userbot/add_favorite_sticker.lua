--- Add favorite sticker through TDLib addFavoriteSticker.
-- @module titogramlua.methods.userbot.add_favorite_sticker
-- @usage client:add_favorite_sticker(params, callback)
-- @param params table with TDLib fields: sticker:InputFile
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('addFavoriteSticker', {['sticker'] = 'InputFile'}, nil, nil, nil)
