--- Delete chat admin invite links through TDLib deleteAllRevokedChatInviteLinks.
-- @module titogramlua.methods.userbot.delete_chat_admin_invite_links
-- @usage client:delete_chat_admin_invite_links(params, callback)
-- @param params table with TDLib fields: chat_id:int53, creator_user_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteAllRevokedChatInviteLinks', {['chat_id'] = 'int53', ['creator_user_id'] = 'int53'}, nil, nil, nil)
