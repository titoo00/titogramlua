--- Send gift through TDLib sendGift.
-- @module titogramlua.methods.userbot.send_gift
-- @usage client:send_gift(params, callback)
-- @param params table with TDLib fields: gift_id:int64, owner_id:MessageSender, text:formattedText, is_private:Bool, pay_for_upgrade:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/send_gift.py
local support = require('titogramlua.methods.userbot._support')
return support.method('sendGift', {['gift_id'] = 'int64', ['owner_id'] = 'MessageSender', ['text'] = 'formattedText', ['is_private'] = 'Bool', ['pay_for_upgrade'] = 'Bool'}, nil, nil, nil)
