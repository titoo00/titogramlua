--- Suggest birthday through TDLib suggestUserBirthdate.
-- @module titogramlua.methods.userbot.suggest_birthday
-- @usage client:suggest_birthday(params, callback)
-- @param params table with TDLib fields: user_id:int53, birthdate:birthdate
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/suggest_birthday.py
local support = require('titogramlua.methods.userbot._support')
return support.method('suggestUserBirthdate', {['user_id'] = 'int53', ['birthdate'] = 'birthdate'}, nil, nil, nil)
