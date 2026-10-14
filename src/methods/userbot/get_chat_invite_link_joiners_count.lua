--- Get chat invite link joiners count through TDLib getChatInviteLinkMembers.
-- @module titogramlua.methods.userbot.get_chat_invite_link_joiners_count
-- @usage client:get_chat_invite_link_joiners_count(params, callback)
-- @param params table with TDLib fields: chat_id:int53, invite_link:string, only_with_expired_subscription:Bool, offset_member:chatInviteLinkMember, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatInviteLinkMembers', {['chat_id'] = 'int53', ['invite_link'] = 'string', ['only_with_expired_subscription'] = 'Bool', ['offset_member'] = 'chatInviteLinkMember', ['limit'] = 'int32'}, {['limit'] = 1}, nil, function(result) return result.total_count end)
