--- Send rich message draft through TDLib sendRichMessageDraft.
-- @module titogramlua.methods.userbot.send_rich_message_draft
-- @usage client:send_rich_message_draft(params, callback)
-- @param params table with TDLib fields: chat_id:int53, forum_topic_id:int32, draft_id:int64, can_stop:Bool, keep_on_stop:Bool, message:inputRichMessage
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/send_rich_message_draft.py
local support = require('titogramlua.methods.userbot._support')
return support.method('sendRichMessageDraft', {['chat_id'] = 'int53', ['forum_topic_id'] = 'int32', ['draft_id'] = 'int64', ['can_stop'] = 'Bool', ['keep_on_stop'] = 'Bool', ['message'] = 'inputRichMessage'}, nil, nil, nil)
