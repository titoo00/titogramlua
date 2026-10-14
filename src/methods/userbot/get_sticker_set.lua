--- Get sticker set through TDLib getStickerSet.
-- @module titogramlua.methods.userbot.get_sticker_set
-- @usage client:get_sticker_set(params, callback)
-- @param params table with TDLib fields: set_id:int64
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getStickerSet', {['set_id'] = 'int64'}, nil, nil, nil)
