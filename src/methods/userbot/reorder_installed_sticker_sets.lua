--- Reorder installed sticker sets through TDLib reorderInstalledStickerSets.
-- @module titogramlua.methods.userbot.reorder_installed_sticker_sets
-- @usage client:reorder_installed_sticker_sets(params, callback)
-- @param params table with TDLib fields: sticker_type:StickerType, sticker_set_ids:vector<int64>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('reorderInstalledStickerSets', {['sticker_type'] = 'StickerType', ['sticker_set_ids'] = 'vector<int64>'}, nil, nil, nil)
