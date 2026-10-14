--- Set chat protected content through TDLib toggleChatHasProtectedContent.
-- @module titogramlua.methods.userbot.set_chat_protected_content
-- @usage client:set_chat_protected_content(params, callback)
-- @param params table with TDLib fields: chat_id:int53, has_protected_content:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('toggleChatHasProtectedContent', {['chat_id'] = 'int53', ['has_protected_content'] = 'Bool'}, nil, nil, nil)
