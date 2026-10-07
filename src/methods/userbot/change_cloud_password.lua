--- Change cloud password through TDLib setPassword.
-- @module titogramlua.methods.userbot.change_cloud_password
-- @usage client:change_cloud_password(params, callback)
-- @param params table with TDLib fields: old_password:string, new_password:string, new_hint:string, set_recovery_email_address:Bool, new_recovery_email_address:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/password/change_cloud_password.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setPassword', {['old_password'] = 'string', ['new_password'] = 'string', ['new_hint'] = 'string', ['set_recovery_email_address'] = 'Bool', ['new_recovery_email_address'] = 'string'}, nil, nil, nil)
