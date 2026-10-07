--- Convert gift to stars through TDLib sellGift.
-- @module titogramlua.methods.userbot.convert_gift_to_stars
-- @usage client:convert_gift_to_stars(params, callback)
-- @param params table with TDLib fields: business_connection_id:string, received_gift_id:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/convert_gift_to_stars.py
local support = require('titogramlua.methods.userbot._support')
return support.method('sellGift', {['business_connection_id'] = 'string', ['received_gift_id'] = 'string'}, nil, nil, nil)
