--- Delete gift collection through TDLib deleteGiftCollection.
-- @module titogramlua.methods.userbot.delete_gift_collection
-- @usage client:delete_gift_collection(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender, collection_id:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteGiftCollection', {['owner_id'] = 'MessageSender', ['collection_id'] = 'int32'}, nil, nil, nil)
