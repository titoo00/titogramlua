--- Search sticker sets through TDLib searchStickerSets.
-- @module titogramlua.methods.userbot.search_sticker_sets
-- @usage client:search_sticker_sets(params, callback)
-- @param params table with TDLib fields: sticker_type:StickerType, query:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('searchStickerSets', {['sticker_type'] = 'StickerType', ['query'] = 'string'}, nil, nil, nil)
