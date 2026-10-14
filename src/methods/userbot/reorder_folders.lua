--- Reorder folders through TDLib reorderChatFolders.
-- @module titogramlua.methods.userbot.reorder_folders
-- @usage client:reorder_folders(params, callback)
-- @param params table with TDLib fields: chat_folder_ids:vector<int32>, main_chat_list_position:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('reorderChatFolders', {['chat_folder_ids'] = 'vector<int32>', ['main_chat_list_position'] = 'int32'}, nil, nil, nil)
