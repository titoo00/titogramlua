--- Get chat gifts count through TDLib getReceivedGifts.
-- @module titogramlua.methods.userbot.get_chat_gifts_count
-- @usage client:get_chat_gifts_count(params, callback)
-- @param params table with TDLib fields: business_connection_id:string, owner_id:MessageSender, collection_id:int32, exclude_unsaved:Bool, exclude_saved:Bool, exclude_unlimited:Bool, exclude_upgradable:Bool, exclude_non_upgradable:Bool, exclude_upgraded:Bool, exclude_without_colors:Bool, exclude_hosted:Bool, sort_by_price:Bool, offset:string, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/get_chat_gifts_count.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getReceivedGifts', {['business_connection_id'] = 'string', ['owner_id'] = 'MessageSender', ['collection_id'] = 'int32', ['exclude_unsaved'] = 'Bool', ['exclude_saved'] = 'Bool', ['exclude_unlimited'] = 'Bool', ['exclude_upgradable'] = 'Bool', ['exclude_non_upgradable'] = 'Bool', ['exclude_upgraded'] = 'Bool', ['exclude_without_colors'] = 'Bool', ['exclude_hosted'] = 'Bool', ['sort_by_price'] = 'Bool', ['offset'] = 'string', ['limit'] = 'int32'}, {['offset'] = '', ['limit'] = 1}, nil, function(result) return result.total_count end)
