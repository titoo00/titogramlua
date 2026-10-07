--- Delete poll option through TDLib deletePollOption.
-- @module titogramlua.methods.userbot.delete_poll_option
-- @usage client:delete_poll_option(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, option_id:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/delete_poll_option.py
local support = require('titogramlua.methods.userbot._support')
return support.method('deletePollOption', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['option_id'] = 'string'}, nil, nil, nil)
