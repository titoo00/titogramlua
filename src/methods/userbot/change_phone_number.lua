--- Change phone number through TDLib checkPhoneNumberCode.
-- @module titogramlua.methods.userbot.change_phone_number
-- @usage client:change_phone_number(params, callback)
-- @param params table with TDLib fields: code:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/auth/change_phone_number.py
local support = require('titogramlua.methods.userbot._support')
return support.method('checkPhoneNumberCode', {['code'] = 'string'}, nil, nil, nil)
