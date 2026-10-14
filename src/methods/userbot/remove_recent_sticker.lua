--- Remove recent sticker through TDLib removeRecentSticker.
-- @module titogramlua.methods.userbot.remove_recent_sticker
-- @usage client:remove_recent_sticker(params, callback)
-- @param params table with TDLib fields: is_attached:Bool, sticker:InputFile
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('removeRecentSticker', {['is_attached'] = 'Bool', ['sticker'] = 'InputFile'}, nil, nil, nil)
