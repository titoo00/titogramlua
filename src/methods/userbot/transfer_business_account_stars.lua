--- Transfer business account stars through TDLib transferBusinessAccountStars.
-- @module titogramlua.methods.userbot.transfer_business_account_stars
-- @usage client:transfer_business_account_stars(params, callback)
-- @param params table with TDLib fields: business_connection_id:string, star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/business/transfer_business_account_stars.py
local support = require('titogramlua.methods.userbot._support')
return support.method('transferBusinessAccountStars', {['business_connection_id'] = 'string', ['star_count'] = 'int53'}, nil, nil, nil)
