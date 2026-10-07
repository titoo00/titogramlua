--- Check password through TDLib checkAuthenticationPassword.
-- @module titogramlua.methods.userbot.check_password
-- @usage client:check_password(params, callback)
-- @param params table with TDLib fields: password:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/auth/check_password.py
local support = require('titogramlua.methods.userbot._support')
return support.method('checkAuthenticationPassword', {['password'] = 'string'}, nil, nil, nil)
