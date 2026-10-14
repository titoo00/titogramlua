--- Send inline bot result through TDLib sendInlineQueryResultMessage.
-- @module titogramlua.methods.userbot.send_inline_bot_result
-- @usage client:send_inline_bot_result(params, callback)
-- @param params table with TDLib fields: chat_id:int53, topic_id:MessageTopic, reply_to:InputMessageReplyTo, options:messageSendOptions, query_id:int64, result_id:string, hide_via_bot:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('sendInlineQueryResultMessage', {['chat_id'] = 'int53', ['topic_id'] = 'MessageTopic', ['reply_to'] = 'InputMessageReplyTo', ['options'] = 'messageSendOptions', ['query_id'] = 'int64', ['result_id'] = 'string', ['hide_via_bot'] = 'Bool'}, nil, nil, nil)
