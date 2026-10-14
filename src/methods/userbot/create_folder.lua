--- Create folder through TDLib createChatFolder.
-- @module titogramlua.methods.userbot.create_folder
-- @usage client:create_folder(params, callback)
-- @param params table with TDLib fields: folder:chatFolder
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('createChatFolder', {['folder'] = 'chatFolder'}, nil, nil, nil)
