--- Set chat permissions through TDLib setChatPermissions.
-- @module titogramlua.methods.userbot.set_chat_permissions
-- @usage client:set_chat_permissions(params, callback)
-- @param params table with TDLib fields: chat_id:int53, permissions:chatPermissions
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatPermissions', {['chat_id'] = 'int53', ['permissions'] = 'chatPermissions'}, nil, nil, nil)
