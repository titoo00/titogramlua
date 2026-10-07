--- Search stickers through TDLib searchStickers.
-- @module titogramlua.methods.userbot.search_stickers
-- @usage client:search_stickers(params, callback)
-- @param params table with TDLib fields: sticker_type:StickerType, emojis:string, query:string, input_language_codes:vector<string>, offset:int32, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/search_stickers.py
local support = require('titogramlua.methods.userbot._support')
return support.method('searchStickers', {['sticker_type'] = 'StickerType', ['emojis'] = 'string', ['query'] = 'string', ['input_language_codes'] = 'vector<string>', ['offset'] = 'int32', ['limit'] = 'int32'}, nil, nil, nil)
