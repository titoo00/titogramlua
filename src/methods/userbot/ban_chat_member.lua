--- Ban chat member through TDLib banChatMember.
-- @module titogramlua.methods.userbot.ban_chat_member
-- @usage client:ban_chat_member(params, callback)
-- @param params table with TDLib fields: chat_id:int53, member_id:MessageSender, banned_until_date:int32, revoke_messages:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/ban_chat_member.py
local support = require('titogramlua.methods.userbot._support')
return support.method('banChatMember', {['chat_id'] = 'int53', ['member_id'] = 'MessageSender', ['banned_until_date'] = 'int32', ['revoke_messages'] = 'Bool'}, nil, nil, nil)
