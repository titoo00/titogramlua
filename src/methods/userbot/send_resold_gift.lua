--- Send resold gift through TDLib sendResoldGift.
-- @module titogramlua.methods.userbot.send_resold_gift
-- @usage client:send_resold_gift(params, callback)
-- @param params table with TDLib fields: gift_name:string, owner_id:MessageSender, price:GiftResalePrice, text:formattedText, is_private:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/send_resold_gift.py
local support = require('titogramlua.methods.userbot._support')
return support.method('sendResoldGift', {['gift_name'] = 'string', ['owner_id'] = 'MessageSender', ['price'] = 'GiftResalePrice', ['text'] = 'formattedText', ['is_private'] = 'Bool'}, nil, nil, nil)
