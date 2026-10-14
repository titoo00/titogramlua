--- Get password hint through TDLib getPasswordState.
-- @module titogramlua.methods.userbot.get_password_hint
-- @usage client:get_password_hint(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getPasswordState', {}, nil, nil, function(result) return result.password_hint end)
