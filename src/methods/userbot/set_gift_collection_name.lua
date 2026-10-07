--- Set gift collection name through TDLib setGiftCollectionName.
-- @module titogramlua.methods.userbot.set_gift_collection_name
-- @usage client:set_gift_collection_name(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender, collection_id:int32, name:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/set_gift_collection_name.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setGiftCollectionName', {['owner_id'] = 'MessageSender', ['collection_id'] = 'int32', ['name'] = 'string'}, nil, nil, nil)
