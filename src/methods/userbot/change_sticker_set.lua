--- Change sticker set through TDLib changeStickerSet.
-- @module titogramlua.methods.userbot.change_sticker_set
-- @usage client:change_sticker_set(params, callback)
-- @param params table with TDLib fields: set_id:int64, is_installed:Bool, is_archived:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('changeStickerSet', {['set_id'] = 'int64', ['is_installed'] = 'Bool', ['is_archived'] = 'Bool'}, nil, nil, nil)
