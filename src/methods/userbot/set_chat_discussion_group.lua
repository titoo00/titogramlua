--- Set chat discussion group through TDLib setChatDiscussionGroup.
-- @module titogramlua.methods.userbot.set_chat_discussion_group
-- @usage client:set_chat_discussion_group(params, callback)
-- @param params table with TDLib fields: chat_id:int53, discussion_chat_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatDiscussionGroup', {['chat_id'] = 'int53', ['discussion_chat_id'] = 'int53'}, nil, nil, nil)
