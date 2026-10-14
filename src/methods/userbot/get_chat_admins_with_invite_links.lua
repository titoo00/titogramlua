--- Get chat admins with invite links through TDLib getChatInviteLinkCounts.
-- @module titogramlua.methods.userbot.get_chat_admins_with_invite_links
-- @usage client:get_chat_admins_with_invite_links(params, callback)
-- @param params table with TDLib fields: chat_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatInviteLinkCounts', {['chat_id'] = 'int53'}, nil, nil, nil)
