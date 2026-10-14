--- Edit chat invite link through TDLib editChatInviteLink.
-- @module titogramlua.methods.userbot.edit_chat_invite_link
-- @usage client:edit_chat_invite_link(params, callback)
-- @param params table with TDLib fields: chat_id:int53, invite_link:string, name:string, expiration_date:int32, member_limit:int32, creates_join_request:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editChatInviteLink', {['chat_id'] = 'int53', ['invite_link'] = 'string', ['name'] = 'string', ['expiration_date'] = 'int32', ['member_limit'] = 'int32', ['creates_join_request'] = 'Bool'}, nil, nil, nil)
