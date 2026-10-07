--- Unban chat member using TDLib setChatMemberStatus.
-- @module titogramlua.methods.userbot.unban_chat_member
-- @usage client:unban_chat_member(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: chat_id:int53, member_id:MessageSender, status:ChatMemberStatus
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('setChatMemberStatus', {['chat_id'] = 'int53', ['member_id'] = 'MessageSender', ['status'] = 'ChatMemberStatus'}, nil, {['status'] = {['@type'] = 'chatMemberStatusLeft'}})
