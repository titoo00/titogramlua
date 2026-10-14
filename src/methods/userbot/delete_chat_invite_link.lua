--- Delete chat invite link through TDLib deleteRevokedChatInviteLink.
-- @module titogramlua.methods.userbot.delete_chat_invite_link
-- @usage client:delete_chat_invite_link(params, callback)
-- @param params table with TDLib fields: chat_id:int53, invite_link:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteRevokedChatInviteLink', {['chat_id'] = 'int53', ['invite_link'] = 'string'}, nil, nil, nil)
