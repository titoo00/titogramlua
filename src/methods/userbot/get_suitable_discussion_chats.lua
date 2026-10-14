--- Get suitable discussion chats through TDLib getSuitableDiscussionChats.
-- @module titogramlua.methods.userbot.get_suitable_discussion_chats
-- @usage client:get_suitable_discussion_chats(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getSuitableDiscussionChats', {}, nil, nil, nil)
