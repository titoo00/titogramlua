--- Get personal channels through TDLib getSuitablePersonalChats.
-- @module titogramlua.methods.userbot.get_personal_channels
-- @usage client:get_personal_channels(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getSuitablePersonalChats', {}, nil, nil, nil)
