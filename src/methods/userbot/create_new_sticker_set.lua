--- Create new sticker set through TDLib createNewStickerSet.
-- @module titogramlua.methods.userbot.create_new_sticker_set
-- @usage client:create_new_sticker_set(params, callback)
-- @param params table with TDLib fields: user_id:int53, title:string, name:string, sticker_type:StickerType, needs_repainting:Bool, stickers:vector<newSticker>, source:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/create_new_sticker_set.py
local support = require('titogramlua.methods.userbot._support')
return support.method('createNewStickerSet', {['user_id'] = 'int53', ['title'] = 'string', ['name'] = 'string', ['sticker_type'] = 'StickerType', ['needs_repainting'] = 'Bool', ['stickers'] = 'vector<newSticker>', ['source'] = 'string'}, nil, nil, nil)
