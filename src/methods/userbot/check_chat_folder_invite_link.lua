--- Check chat folder invite link through TDLib checkChatFolderInviteLink.
-- @module titogramlua.methods.userbot.check_chat_folder_invite_link
-- @usage client:check_chat_folder_invite_link(params, callback)
-- @param params table with TDLib fields: invite_link:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('checkChatFolderInviteLink', {['invite_link'] = 'string'}, nil, nil, nil)
