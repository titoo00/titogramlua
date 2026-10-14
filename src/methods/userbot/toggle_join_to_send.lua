--- Toggle join to send through TDLib toggleSupergroupJoinToSendMessages.
-- @module titogramlua.methods.userbot.toggle_join_to_send
-- @usage client:toggle_join_to_send(params, callback)
-- @param params table with TDLib fields: supergroup_id:int53, join_to_send_messages:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('toggleSupergroupJoinToSendMessages', {['supergroup_id'] = 'int53', ['join_to_send_messages'] = 'Bool'}, nil, nil, nil)
