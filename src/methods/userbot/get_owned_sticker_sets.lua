--- Get owned sticker sets through TDLib getOwnedStickerSets.
-- @module titogramlua.methods.userbot.get_owned_sticker_sets
-- @usage client:get_owned_sticker_sets(params, callback)
-- @param params table with TDLib fields: offset_sticker_set_id:int64, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/get_owned_sticker_sets.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getOwnedStickerSets', {['offset_sticker_set_id'] = 'int64', ['limit'] = 'int32'}, nil, nil, nil)
