--- Send message draft through TDLib sendTextMessageDraft.
-- @module titogramlua.methods.userbot.send_message_draft
-- @usage client:send_message_draft(params, callback)
-- @param params table with TDLib fields: chat_id:int53, forum_topic_id:int32, draft_id:int64, can_stop:Bool, keep_on_stop:Bool, text:formattedText
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('sendTextMessageDraft', {['chat_id'] = 'int53', ['forum_topic_id'] = 'int32', ['draft_id'] = 'int64', ['can_stop'] = 'Bool', ['keep_on_stop'] = 'Bool', ['text'] = 'formattedText'}, nil, nil, nil)
