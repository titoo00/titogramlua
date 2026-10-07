--- Sign in through TDLib checkAuthenticationCode.
-- @module titogramlua.methods.userbot.sign_in
-- @usage client:sign_in(params, callback)
-- @param params table with TDLib fields: code:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/auth/sign_in.py
local support = require('titogramlua.methods.userbot._support')
return support.method('checkAuthenticationCode', {['code'] = 'string'}, nil, nil, nil)
