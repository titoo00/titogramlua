--- Get chat admin invite links through TDLib getChatInviteLinks.
-- @module titogramlua.methods.userbot.get_chat_admin_invite_links
-- @usage client:get_chat_admin_invite_links(params, callback)
-- @param params table with TDLib fields: chat_id:int53, creator_user_id:int53, is_revoked:Bool, offset_date:int32, offset_invite_link:string, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatInviteLinks', {['chat_id'] = 'int53', ['creator_user_id'] = 'int53', ['is_revoked'] = 'Bool', ['offset_date'] = 'int32', ['offset_invite_link'] = 'string', ['limit'] = 'int32'}, nil, nil, nil)
