--- Sign up through TDLib registerUser.
-- @module titogramlua.methods.userbot.sign_up
-- @usage client:sign_up(params, callback)
-- @param params table with TDLib fields: first_name:string, last_name:string, disable_notification:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('registerUser', {['first_name'] = 'string', ['last_name'] = 'string', ['disable_notification'] = 'Bool'}, nil, nil, nil)
