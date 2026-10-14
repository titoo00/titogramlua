--- Send chat action through TDLib sendChatAction.
-- @module titogramlua.methods.userbot.send_chat_action
-- @usage client:send_chat_action(params, callback)
-- @param params table with TDLib fields: chat_id:int53, topic_id:MessageTopic, business_connection_id:string, action:ChatAction
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('sendChatAction', {['chat_id'] = 'int53', ['topic_id'] = 'MessageTopic', ['business_connection_id'] = 'string', ['action'] = 'ChatAction'}, nil, nil, nil)
