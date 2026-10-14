--- Edit folder invite link through TDLib editChatFolderInviteLink.
-- @module titogramlua.methods.userbot.edit_folder_invite_link
-- @usage client:edit_folder_invite_link(params, callback)
-- @param params table with TDLib fields: chat_folder_id:int32, invite_link:string, name:string, chat_ids:vector<int53>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('editChatFolderInviteLink', {['chat_folder_id'] = 'int32', ['invite_link'] = 'string', ['name'] = 'string', ['chat_ids'] = 'vector<int53>'}, nil, nil, nil)
