--- Get sticker set through TDLib getStickerSet.
-- @module titogramlua.methods.userbot.get_sticker_set
-- @usage client:get_sticker_set(params, callback)
-- @param params table with TDLib fields: set_id:int64
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/get_sticker_set.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getStickerSet', {['set_id'] = 'int64'}, nil, nil, nil)
