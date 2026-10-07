--- Toggle forum topics through TDLib toggleSupergroupIsForum.
-- @module titogramlua.methods.userbot.toggle_forum_topics
-- @usage client:toggle_forum_topics(params, callback)
-- @param params table with TDLib fields: supergroup_id:int53, is_forum:Bool, has_forum_tabs:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/toggle_forum_topics.py
local support = require('titogramlua.methods.userbot._support')
return support.method('toggleSupergroupIsForum', {['supergroup_id'] = 'int53', ['is_forum'] = 'Bool', ['has_forum_tabs'] = 'Bool'}, nil, nil, nil)
