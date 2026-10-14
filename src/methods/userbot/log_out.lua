--- Log out through TDLib logOut.
-- @module titogramlua.methods.userbot.log_out
-- @usage client:log_out(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('logOut', {}, nil, nil, nil)
