--- Get blocked message senders through TDLib getBlockedMessageSenders.
-- @module titogramlua.methods.userbot.get_blocked_message_senders
-- @usage client:get_blocked_message_senders(params, callback)
-- @param params table with TDLib fields: block_list:BlockList, offset:int32, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getBlockedMessageSenders', {['block_list'] = 'BlockList', ['offset'] = 'int32', ['limit'] = 'int32'}, nil, nil, nil)
