--- Reset sessions through TDLib terminateAllOtherSessions.
-- @module titogramlua.methods.userbot.reset_sessions
-- @usage client:reset_sessions(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/auth/reset_sessions.py
local support = require('titogramlua.methods.userbot._support')
return support.method('terminateAllOtherSessions', {}, nil, nil, nil)
