--- Edit star subscription through TDLib editStarSubscription.
-- @module titogramlua.methods.userbot.edit_star_subscription
-- @usage client:edit_star_subscription(params, callback)
-- @param params table with TDLib fields: subscription_id:string, is_canceled:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editStarSubscription', {['subscription_id'] = 'string', ['is_canceled'] = 'Bool'}, nil, nil, nil)
