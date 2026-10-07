--- Set slow mode through TDLib setChatSlowModeDelay.
-- @module titogramlua.methods.userbot.set_slow_mode
-- @usage client:set_slow_mode(params, callback)
-- @param params table with TDLib fields: chat_id:int53, slow_mode_delay:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/set_slow_mode.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatSlowModeDelay', {['chat_id'] = 'int53', ['slow_mode_delay'] = 'int32'}, nil, nil, nil)
