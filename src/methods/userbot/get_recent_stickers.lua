--- Get recent stickers through TDLib getRecentStickers.
-- @module titogramlua.methods.userbot.get_recent_stickers
-- @usage client:get_recent_stickers(params, callback)
-- @param params table with TDLib fields: is_attached:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getRecentStickers', {['is_attached'] = 'Bool'}, nil, nil, nil)
