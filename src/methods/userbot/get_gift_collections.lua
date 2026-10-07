--- Get gift collections through TDLib getGiftCollections.
-- @module titogramlua.methods.userbot.get_gift_collections
-- @usage client:get_gift_collections(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/get_gift_collections.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getGiftCollections', {['owner_id'] = 'MessageSender'}, nil, nil, nil)
