--- Remove collection gifts through TDLib removeGiftCollectionGifts.
-- @module titogramlua.methods.userbot.remove_collection_gifts
-- @usage client:remove_collection_gifts(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender, collection_id:int32, received_gift_ids:vector<string>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/remove_collection_gifts.py
local support = require('titogramlua.methods.userbot._support')
return support.method('removeGiftCollectionGifts', {['owner_id'] = 'MessageSender', ['collection_id'] = 'int32', ['received_gift_ids'] = 'vector<string>'}, nil, nil, nil)
