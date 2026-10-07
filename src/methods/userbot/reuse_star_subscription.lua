--- Reuse star subscription through TDLib reuseStarSubscription.
-- @module titogramlua.methods.userbot.reuse_star_subscription
-- @usage client:reuse_star_subscription(params, callback)
-- @param params table with TDLib fields: subscription_id:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/reuse_star_subscription.py
local support = require('titogramlua.methods.userbot._support')
return support.method('reuseStarSubscription', {['subscription_id'] = 'string'}, nil, nil, nil)
