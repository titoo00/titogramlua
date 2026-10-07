--- Clear recent stickers through TDLib clearRecentStickers.
-- @module titogramlua.methods.userbot.clear_recent_stickers
-- @usage client:clear_recent_stickers(params, callback)
-- @param params table with TDLib fields: is_attached:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/clear_recent_stickers.py
local support = require('titogramlua.methods.userbot._support')
return support.method('clearRecentStickers', {['is_attached'] = 'Bool'}, nil, nil, nil)
