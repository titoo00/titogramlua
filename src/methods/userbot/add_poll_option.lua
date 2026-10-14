--- Add poll option through TDLib addPollOption.
-- @module titogramlua.methods.userbot.add_poll_option
-- @usage client:add_poll_option(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, option:inputPollOption
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('addPollOption', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['option'] = 'inputPollOption'}, nil, nil, nil)
