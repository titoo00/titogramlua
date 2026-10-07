--- Remove favorite sticker through TDLib removeFavoriteSticker.
-- @module titogramlua.methods.userbot.remove_favorite_sticker
-- @usage client:remove_favorite_sticker(params, callback)
-- @param params table with TDLib fields: sticker:InputFile
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/remove_favorite_sticker.py
local support = require('titogramlua.methods.userbot._support')
return support.method('removeFavoriteSticker', {['sticker'] = 'InputFile'}, nil, nil, nil)
