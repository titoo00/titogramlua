--- Get business account star balance through TDLib getBusinessAccountStarAmount.
-- @module titogramlua.methods.userbot.get_business_account_star_balance
-- @usage client:get_business_account_star_balance(params, callback)
-- @param params table with TDLib fields: business_connection_id:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/business/get_business_account_star_balance.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getBusinessAccountStarAmount', {['business_connection_id'] = 'string'}, nil, nil, nil)
