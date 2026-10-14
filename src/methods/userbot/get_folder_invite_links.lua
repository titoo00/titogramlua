--- Get folder invite links through TDLib getChatFolderInviteLinks.
-- @module titogramlua.methods.userbot.get_folder_invite_links
-- @usage client:get_folder_invite_links(params, callback)
-- @param params table with TDLib fields: chat_folder_id:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatFolderInviteLinks', {['chat_folder_id'] = 'int32'}, nil, nil, nil)
