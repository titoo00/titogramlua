--- Get chat invite link through TDLib getChatInviteLink.
-- @module titogramlua.methods.userbot.get_chat_invite_link
-- @usage client:get_chat_invite_link(params, callback)
-- @param params table with TDLib fields: chat_id:int53, invite_link:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatInviteLink', {['chat_id'] = 'int53', ['invite_link'] = 'string'}, nil, nil, nil)
