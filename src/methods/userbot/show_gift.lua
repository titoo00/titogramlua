--- Show gift through TDLib toggleGiftIsSaved.
-- @module titogramlua.methods.userbot.show_gift
-- @usage client:show_gift(params, callback)
-- @param params table with TDLib fields: received_gift_id:string, is_saved:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('toggleGiftIsSaved', {['received_gift_id'] = 'string', ['is_saved'] = 'Bool'}, nil, {['is_saved'] = true}, nil)
