--- Delete folder through TDLib deleteChatFolder.
-- @module titogramlua.methods.userbot.delete_folder
-- @usage client:delete_folder(params, callback)
-- @param params table with TDLib fields: chat_folder_id:int32, leave_chat_ids:vector<int53>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/delete_folder.py
local support = require('titogramlua.methods.userbot._support')
return support.method('deleteChatFolder', {['chat_folder_id'] = 'int32', ['leave_chat_ids'] = 'vector<int53>'}, nil, nil, nil)
