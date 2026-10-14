--- Toggle folder tags through TDLib toggleChatFolderTags.
-- @module titogramlua.methods.userbot.toggle_folder_tags
-- @usage client:toggle_folder_tags(params, callback)
-- @param params table with TDLib fields: are_tags_enabled:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('toggleChatFolderTags', {['are_tags_enabled'] = 'Bool'}, nil, nil, nil)
