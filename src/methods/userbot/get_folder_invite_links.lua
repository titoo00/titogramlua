--- Get folder invite links through TDLib getChatFolderInviteLinks.
-- @module titogramlua.methods.userbot.get_folder_invite_links
-- @usage client:get_folder_invite_links(params, callback)
-- @param params table with TDLib fields: chat_folder_id:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/get_folder_invite_links.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getChatFolderInviteLinks', {['chat_folder_id'] = 'int32'}, nil, nil, nil)
