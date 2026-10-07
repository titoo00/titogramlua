--- Get boosts status through TDLib getChatBoostStatus.
-- @module titogramlua.methods.userbot.get_boosts_status
-- @usage client:get_boosts_status(params, callback)
-- @param params table with TDLib fields: chat_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/premium/get_boosts_status.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatBoostStatus', {['chat_id'] = 'int53'}, nil, nil, nil)
