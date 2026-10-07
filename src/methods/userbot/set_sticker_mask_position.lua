--- Set sticker mask position through TDLib setStickerMaskPosition.
-- @module titogramlua.methods.userbot.set_sticker_mask_position
-- @usage client:set_sticker_mask_position(params, callback)
-- @param params table with TDLib fields: sticker:InputFile, mask_position:maskPosition
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/set_sticker_mask_position.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setStickerMaskPosition', {['sticker'] = 'InputFile', ['mask_position'] = 'maskPosition'}, nil, nil, nil)
