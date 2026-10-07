--- Restrict chat member through TDLib setChatMemberStatus.
-- @module titogramlua.methods.userbot.restrict_chat_member
-- @usage client:restrict_chat_member(params, callback)
-- @param params table with TDLib fields: chat_id:int53, member_id:MessageSender, status:ChatMemberStatus
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/restrict_chat_member.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatMemberStatus', {['chat_id'] = 'int53', ['member_id'] = 'MessageSender', ['status'] = 'ChatMemberStatus'}, nil, nil, nil)
