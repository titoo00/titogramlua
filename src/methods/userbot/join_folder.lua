--- Join folder through TDLib addChatFolderByInviteLink.
-- @module titogramlua.methods.userbot.join_folder
-- @usage client:join_folder(params, callback)
-- @param params table with TDLib fields: invite_link:string, chat_ids:vector<int53>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('addChatFolderByInviteLink', {['invite_link'] = 'string', ['chat_ids'] = 'vector<int53>'}, nil, nil, nil)
