--- Revoke chat invite link through TDLib revokeChatInviteLink.
-- @module titogramlua.methods.userbot.revoke_chat_invite_link
-- @usage client:revoke_chat_invite_link(params, callback)
-- @param params table with TDLib fields: chat_id:int53, invite_link:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/invite_links/revoke_chat_invite_link.py
local support = require('titogramlua.methods.userbot._support')
return support.method('revokeChatInviteLink', {['chat_id'] = 'int53', ['invite_link'] = 'string'}, nil, nil, nil)
