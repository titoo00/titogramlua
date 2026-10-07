--- Search gifts for resale through TDLib searchGiftsForResale.
-- @module titogramlua.methods.userbot.search_gifts_for_resale
-- @usage client:search_gifts_for_resale(params, callback)
-- @param params table with TDLib fields: gift_id:int64, order:GiftForResaleOrder, for_crafting:Bool, for_stars:Bool, attributes:vector<UpgradedGiftAttributeId>, offset:string, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/search_gifts_for_resale.py
local support = require('titogramlua.methods.userbot._support')
return support.method('searchGiftsForResale', {['gift_id'] = 'int64', ['order'] = 'GiftForResaleOrder', ['for_crafting'] = 'Bool', ['for_stars'] = 'Bool', ['attributes'] = 'vector<UpgradedGiftAttributeId>', ['offset'] = 'string', ['limit'] = 'int32'}, nil, nil, nil)
