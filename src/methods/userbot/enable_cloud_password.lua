--- Enable cloud password using TDLib setPassword.
-- @module titogramlua.methods.userbot.enable_cloud_password
-- @usage client:enable_cloud_password(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: old_password:string, new_password:string, new_hint:string, set_recovery_email_address:Bool, new_recovery_email_address:string
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('setPassword', {['old_password'] = 'string', ['new_password'] = 'string', ['new_hint'] = 'string', ['set_recovery_email_address'] = 'Bool', ['new_recovery_email_address'] = 'string'}, {['old_password'] = ''}, nil)
