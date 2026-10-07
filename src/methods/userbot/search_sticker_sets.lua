--- Search sticker sets through TDLib searchStickerSets.
-- @module titogramlua.methods.userbot.search_sticker_sets
-- @usage client:search_sticker_sets(params, callback)
-- @param params table with TDLib fields: sticker_type:StickerType, query:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/search_sticker_sets.py
local support = require('titogramlua.methods.userbot._support')
return support.method('searchStickerSets', {['sticker_type'] = 'StickerType', ['query'] = 'string'}, nil, nil, nil)
