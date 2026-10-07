--- Delete sticker from set through TDLib removeStickerFromSet.
-- @module titogramlua.methods.userbot.delete_sticker_from_set
-- @usage client:delete_sticker_from_set(params, callback)
-- @param params table with TDLib fields: sticker:InputFile
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/delete_sticker_from_set.py
local support = require('titogramlua.methods.userbot._support')
return support.method('removeStickerFromSet', {['sticker'] = 'InputFile'}, nil, nil, nil)
