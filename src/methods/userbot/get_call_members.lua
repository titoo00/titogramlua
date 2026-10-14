--- Get call members through TDLib getGroupCallParticipants.
-- @module titogramlua.methods.userbot.get_call_members
-- @usage client:get_call_members(params, callback)
-- @param params table with TDLib fields: input_group_call:InputGroupCall, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getGroupCallParticipants', {['input_group_call'] = 'InputGroupCall', ['limit'] = 'int32'}, nil, nil, nil)
