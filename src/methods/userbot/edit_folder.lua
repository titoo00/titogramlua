--- Edit folder through TDLib editChatFolder.
-- @module titogramlua.methods.userbot.edit_folder
-- @usage client:edit_folder(params, callback)
-- @param params table with TDLib fields: chat_folder_id:int32, folder:chatFolder
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/edit_folder.py
local support = require('titogramlua.methods.userbot._support')
return support.method('editChatFolder', {['chat_folder_id'] = 'int32', ['folder'] = 'chatFolder'}, nil, nil, nil)
