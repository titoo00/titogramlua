--- Get chat admins with invite links through TDLib getChatInviteLinkCounts.
-- @module titogramlua.methods.userbot.get_chat_admins_with_invite_links
-- @usage client:get_chat_admins_with_invite_links(params, callback)
-- @param params table with TDLib fields: chat_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/invite_links/get_chat_admins_with_invite_links.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatInviteLinkCounts', {['chat_id'] = 'int53'}, nil, nil, nil)
