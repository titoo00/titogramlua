--- Set sticker set title through TDLib setStickerSetTitle.
-- @module titogramlua.methods.userbot.set_sticker_set_title
-- @usage client:set_sticker_set_title(params, callback)
-- @param params table with TDLib fields: name:string, title:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setStickerSetTitle', {['name'] = 'string', ['title'] = 'string'}, nil, nil, nil)
