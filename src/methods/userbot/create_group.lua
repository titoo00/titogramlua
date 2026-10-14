--- Create group through TDLib createNewBasicGroupChat.
-- @module titogramlua.methods.userbot.create_group
-- @usage client:create_group(params, callback)
-- @param params table with TDLib fields: user_ids:vector<int53>, title:string, message_auto_delete_time:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('createNewBasicGroupChat', {['user_ids'] = 'vector<int53>', ['title'] = 'string', ['message_auto_delete_time'] = 'int32'}, nil, nil, nil)
