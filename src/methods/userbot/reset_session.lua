--- Reset session through TDLib terminateSession.
-- @module titogramlua.methods.userbot.reset_session
-- @usage client:reset_session(params, callback)
-- @param params table with TDLib fields: session_id:int64
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/auth/reset_session.py
local support = require('titogramlua.methods.userbot._support')
return support.method('terminateSession', {['session_id'] = 'int64'}, nil, nil, nil)
