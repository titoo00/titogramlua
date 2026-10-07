--- Drop gift original details through TDLib dropGiftOriginalDetails.
-- @module titogramlua.methods.userbot.drop_gift_original_details
-- @usage client:drop_gift_original_details(params, callback)
-- @param params table with TDLib fields: received_gift_id:string, star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/drop_gift_original_details.py
local support = require('titogramlua.methods.userbot._support')
return support.method('dropGiftOriginalDetails', {['received_gift_id'] = 'string', ['star_count'] = 'int53'}, nil, nil, nil)
