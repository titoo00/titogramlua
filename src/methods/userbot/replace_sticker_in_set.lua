--- Replace sticker in set through TDLib replaceStickerInSet.
-- @module titogramlua.methods.userbot.replace_sticker_in_set
-- @usage client:replace_sticker_in_set(params, callback)
-- @param params table with TDLib fields: user_id:int53, name:string, old_sticker:InputFile, new_sticker:newSticker
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('replaceStickerInSet', {['user_id'] = 'int53', ['name'] = 'string', ['old_sticker'] = 'InputFile', ['new_sticker'] = 'newSticker'}, nil, nil, nil)
