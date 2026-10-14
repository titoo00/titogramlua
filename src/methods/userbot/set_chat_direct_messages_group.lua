--- Set chat direct messages group through TDLib setChatDirectMessagesGroup.
-- @module titogramlua.methods.userbot.set_chat_direct_messages_group
-- @usage client:set_chat_direct_messages_group(params, callback)
-- @param params table with TDLib fields: chat_id:int53, is_enabled:Bool, paid_message_star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatDirectMessagesGroup', {['chat_id'] = 'int53', ['is_enabled'] = 'Bool', ['paid_message_star_count'] = 'int53'}, nil, nil, nil)
