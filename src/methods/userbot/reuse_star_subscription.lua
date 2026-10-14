--- Reuse star subscription through TDLib reuseStarSubscription.
-- @module titogramlua.methods.userbot.reuse_star_subscription
-- @usage client:reuse_star_subscription(params, callback)
-- @param params table with TDLib fields: subscription_id:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('reuseStarSubscription', {['subscription_id'] = 'string'}, nil, nil, nil)
