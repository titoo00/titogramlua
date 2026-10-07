--- Accept terms of service through TDLib acceptTermsOfService.
-- @module titogramlua.methods.userbot.accept_terms_of_service
-- @usage client:accept_terms_of_service(params, callback)
-- @param params table with TDLib fields: terms_of_service_id:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/auth/accept_terms_of_service.py
local support = require('titogramlua.methods.userbot._support')
return support.method('acceptTermsOfService', {['terms_of_service_id'] = 'string'}, nil, nil, nil)
