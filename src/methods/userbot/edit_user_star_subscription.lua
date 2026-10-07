--- Edit user star subscription through TDLib editUserStarSubscription.
-- @module titogramlua.methods.userbot.edit_user_star_subscription
-- @usage client:edit_user_star_subscription(params, callback)
-- @param params table with TDLib fields: user_id:int53, telegram_payment_charge_id:string, is_canceled:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/edit_user_star_subscription.py
local support = require('titogramlua.methods.userbot._support')
return support.method('editUserStarSubscription', {['user_id'] = 'int53', ['telegram_payment_charge_id'] = 'string', ['is_canceled'] = 'Bool'}, nil, nil, nil)
