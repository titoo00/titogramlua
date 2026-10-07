--- Get suggested sticker set name through TDLib getSuggestedStickerSetName.
-- @module titogramlua.methods.userbot.get_suggested_sticker_set_name
-- @usage client:get_suggested_sticker_set_name(params, callback)
-- @param params table with TDLib fields: title:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/get_suggested_sticker_set_name.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getSuggestedStickerSetName', {['title'] = 'string'}, nil, nil, nil)
