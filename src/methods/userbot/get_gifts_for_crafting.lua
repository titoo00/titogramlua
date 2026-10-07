--- Get gifts for crafting through TDLib getGiftsForCrafting.
-- @module titogramlua.methods.userbot.get_gifts_for_crafting
-- @usage client:get_gifts_for_crafting(params, callback)
-- @param params table with TDLib fields: regular_gift_id:int64, offset:string, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/get_gifts_for_crafting.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getGiftsForCrafting', {['regular_gift_id'] = 'int64', ['offset'] = 'string', ['limit'] = 'int32'}, nil, nil, nil)
