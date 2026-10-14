--- Apply boost through TDLib boostChat.
-- @module titogramlua.methods.userbot.apply_boost
-- @usage client:apply_boost(params, callback)
-- @param params table with TDLib fields: chat_id:int53, slot_ids:vector<int32>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('boostChat', {['chat_id'] = 'int53', ['slot_ids'] = 'vector<int32>'}, nil, nil, nil)
