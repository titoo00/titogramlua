--- Set chat member tag through TDLib setChatMemberTag.
-- @module titogramlua.methods.userbot.set_chat_member_tag
-- @usage client:set_chat_member_tag(params, callback)
-- @param params table with TDLib fields: chat_id:int53, user_id:int53, tag:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/set_chat_member_tag.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatMemberTag', {['chat_id'] = 'int53', ['user_id'] = 'int53', ['tag'] = 'string'}, nil, nil, nil)
