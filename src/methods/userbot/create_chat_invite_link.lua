--- Create chat invite link through TDLib createChatInviteLink.
-- @module titogramlua.methods.userbot.create_chat_invite_link
-- @usage client:create_chat_invite_link(params, callback)
-- @param params table with TDLib fields: chat_id:int53, name:string, expiration_date:int32, member_limit:int32, creates_join_request:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/invite_links/create_chat_invite_link.py
local support = require('titogramlua.methods.userbot._support')
return support.method('createChatInviteLink', {['chat_id'] = 'int53', ['name'] = 'string', ['expiration_date'] = 'int32', ['member_limit'] = 'int32', ['creates_join_request'] = 'Bool'}, nil, nil, nil)
