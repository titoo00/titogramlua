--- Delete channel through TDLib deleteChat.
-- @module titogramlua.methods.userbot.delete_channel
-- @usage client:delete_channel(params, callback)
-- @param params table with TDLib fields: chat_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteChat', {['chat_id'] = 'int53'}, nil, nil, nil)
