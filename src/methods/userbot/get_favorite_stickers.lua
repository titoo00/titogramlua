--- Get favorite stickers through TDLib getFavoriteStickers.
-- @module titogramlua.methods.userbot.get_favorite_stickers
-- @usage client:get_favorite_stickers(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getFavoriteStickers', {}, nil, nil, nil)
