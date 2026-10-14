--- Create forum topic through TDLib createForumTopic.
-- @module titogramlua.methods.userbot.create_forum_topic
-- @usage client:create_forum_topic(params, callback)
-- @param params table with TDLib fields: chat_id:int53, name:string, is_name_implicit:Bool, icon:forumTopicIcon
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('createForumTopic', {['chat_id'] = 'int53', ['name'] = 'string', ['is_name_implicit'] = 'Bool', ['icon'] = 'forumTopicIcon'}, nil, nil, nil)
