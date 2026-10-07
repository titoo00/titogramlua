--- Get favorite stickers through TDLib getFavoriteStickers.
-- @module titogramlua.methods.userbot.get_favorite_stickers
-- @usage client:get_favorite_stickers(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/get_favorite_stickers.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getFavoriteStickers', {}, nil, nil, nil)
