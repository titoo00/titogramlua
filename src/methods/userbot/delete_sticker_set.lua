--- Delete sticker set through TDLib deleteStickerSet.
-- @module titogramlua.methods.userbot.delete_sticker_set
-- @usage client:delete_sticker_set(params, callback)
-- @param params table with TDLib fields: name:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteStickerSet', {['name'] = 'string'}, nil, nil, nil)
