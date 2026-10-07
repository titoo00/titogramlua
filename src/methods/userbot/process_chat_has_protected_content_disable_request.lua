--- Process chat has protected content disable request through TDLib processChatHasProtectedContentDisableRequest.
-- @module titogramlua.methods.userbot.process_chat_has_protected_content_disable_request
-- @usage client:process_chat_has_protected_content_disable_request(params, callback)
-- @param params table with TDLib fields: chat_id:int53, request_message_id:int53, approve:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/process_chat_has_protected_content_disable_request.py
local support = require('titogramlua.methods.userbot._support')
return support.method('processChatHasProtectedContentDisableRequest', {['chat_id'] = 'int53', ['request_message_id'] = 'int53', ['approve'] = 'Bool'}, nil, nil, nil)
