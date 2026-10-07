--- Edit forum topic through TDLib editForumTopic.
-- @module titogramlua.methods.userbot.edit_forum_topic
-- @usage client:edit_forum_topic(params, callback)
-- @param params table with TDLib fields: chat_id:int53, forum_topic_id:int32, name:string, edit_icon_custom_emoji:Bool, icon_custom_emoji_id:int64
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/edit_forum_topic.py
local support = require('titogramlua.methods.userbot._support')
return support.method('editForumTopic', {['chat_id'] = 'int53', ['forum_topic_id'] = 'int32', ['name'] = 'string', ['edit_icon_custom_emoji'] = 'Bool', ['icon_custom_emoji_id'] = 'int64'}, nil, nil, nil)
