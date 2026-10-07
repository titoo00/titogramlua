--- Upload sticker file through TDLib uploadStickerFile.
-- @module titogramlua.methods.userbot.upload_sticker_file
-- @usage client:upload_sticker_file(params, callback)
-- @param params table with TDLib fields: user_id:int53, sticker_format:StickerFormat, sticker:InputFile
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/upload_sticker_file.py
local support = require('titogramlua.methods.userbot._support')
return support.method('uploadStickerFile', {['user_id'] = 'int53', ['sticker_format'] = 'StickerFormat', ['sticker'] = 'InputFile'}, nil, nil, nil)
