--- Delete ephemeral message through TDLib deleteEphemeralMessage.
-- @module titogramlua.methods.userbot.delete_ephemeral_message
-- @usage client:delete_ephemeral_message(params, callback)
-- @param params table with TDLib fields: chat_id:int53, receiver_user_id:int53, ephemeral_message_id:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/delete_ephemeral_message.py
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteEphemeralMessage', {['chat_id'] = 'int53', ['receiver_user_id'] = 'int53', ['ephemeral_message_id'] = 'int32'}, nil, nil, nil)
