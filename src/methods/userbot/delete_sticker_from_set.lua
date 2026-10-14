--- Delete sticker from set through TDLib removeStickerFromSet.
-- @module titogramlua.methods.userbot.delete_sticker_from_set
-- @usage client:delete_sticker_from_set(params, callback)
-- @param params table with TDLib fields: sticker:InputFile
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('removeStickerFromSet', {['sticker'] = 'InputFile'}, nil, nil, nil)
