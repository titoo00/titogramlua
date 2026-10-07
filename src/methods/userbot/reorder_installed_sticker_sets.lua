--- Reorder installed sticker sets through TDLib reorderInstalledStickerSets.
-- @module titogramlua.methods.userbot.reorder_installed_sticker_sets
-- @usage client:reorder_installed_sticker_sets(params, callback)
-- @param params table with TDLib fields: sticker_type:StickerType, sticker_set_ids:vector<int64>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/reorder_installed_sticker_sets.py
local support = require('titogramlua.methods.userbot._support')
return support.method('reorderInstalledStickerSets', {['sticker_type'] = 'StickerType', ['sticker_set_ids'] = 'vector<int64>'}, nil, nil, nil)
