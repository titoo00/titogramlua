--- Create folder through TDLib createChatFolder.
-- @module titogramlua.methods.userbot.create_folder
-- @usage client:create_folder(params, callback)
-- @param params table with TDLib fields: folder:chatFolder
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/create_folder.py
local support = require('titogramlua.methods.userbot._support')
return support.method('createChatFolder', {['folder'] = 'chatFolder'}, nil, nil, nil)
