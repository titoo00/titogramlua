--- Delete gift collection through TDLib deleteGiftCollection.
-- @module titogramlua.methods.userbot.delete_gift_collection
-- @usage client:delete_gift_collection(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender, collection_id:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/delete_gift_collection.py
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteGiftCollection', {['owner_id'] = 'MessageSender', ['collection_id'] = 'int32'}, nil, nil, nil)
