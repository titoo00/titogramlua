--- Set sticker set thumbnail through TDLib setStickerSetThumbnail.
-- @module titogramlua.methods.userbot.set_sticker_set_thumbnail
-- @usage client:set_sticker_set_thumbnail(params, callback)
-- @param params table with TDLib fields: user_id:int53, name:string, thumbnail:InputFile, format:StickerFormat
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/set_sticker_set_thumbnail.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setStickerSetThumbnail', {['user_id'] = 'int53', ['name'] = 'string', ['thumbnail'] = 'InputFile', ['format'] = 'StickerFormat'}, nil, nil, nil)
