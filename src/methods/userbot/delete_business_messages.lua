--- Delete business messages through TDLib deleteBusinessMessages.
-- @module titogramlua.methods.userbot.delete_business_messages
-- @usage client:delete_business_messages(params, callback)
-- @param params table with TDLib fields: business_connection_id:string, message_ids:vector<int53>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/business/delete_business_messages.py
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteBusinessMessages', {['business_connection_id'] = 'string', ['message_ids'] = 'vector<int53>'}, nil, nil, nil)
