--- Get active sessions through TDLib getActiveSessions.
-- @module titogramlua.methods.userbot.get_active_sessions
-- @usage client:get_active_sessions(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getActiveSessions', {}, nil, nil, nil)
