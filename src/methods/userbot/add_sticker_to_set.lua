--- Add sticker to set through TDLib addStickerToSet.
-- @module titogramlua.methods.userbot.add_sticker_to_set
-- @usage client:add_sticker_to_set(params, callback)
-- @param params table with TDLib fields: user_id:int53, name:string, sticker:newSticker
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('addStickerToSet', {['user_id'] = 'int53', ['name'] = 'string', ['sticker'] = 'newSticker'}, nil, nil, nil)
