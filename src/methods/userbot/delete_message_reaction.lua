--- Delete message reaction through TDLib deleteMessageReactionsFromSender.
-- @module titogramlua.methods.userbot.delete_message_reaction
-- @usage client:delete_message_reaction(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, sender_id:MessageSender
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteMessageReactionsFromSender', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['sender_id'] = 'MessageSender'}, nil, nil, nil)
