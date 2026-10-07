--- Create gift collection through TDLib createGiftCollection.
-- @module titogramlua.methods.userbot.create_gift_collection
-- @usage client:create_gift_collection(params, callback)
-- @param params table with TDLib fields: owner_id:MessageSender, name:string, received_gift_ids:vector<string>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/create_gift_collection.py
local support = require('titogramlua.methods.userbot._support')
return support.method('createGiftCollection', {['owner_id'] = 'MessageSender', ['name'] = 'string', ['received_gift_ids'] = 'vector<string>'}, nil, nil, nil)
