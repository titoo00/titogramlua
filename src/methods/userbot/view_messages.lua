--- View messages through TDLib viewMessages.
-- @module titogramlua.methods.userbot.view_messages
-- @usage client:view_messages(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_ids:vector<int53>, source:MessageSource, force_read:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('viewMessages', {['chat_id'] = 'int53', ['message_ids'] = 'vector<int53>', ['source'] = 'MessageSource', ['force_read'] = 'Bool'}, nil, nil, nil)
