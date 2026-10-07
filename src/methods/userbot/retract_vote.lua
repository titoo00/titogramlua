--- Retract vote through TDLib setPollAnswer.
-- @module titogramlua.methods.userbot.retract_vote
-- @usage client:retract_vote(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, option_ids:vector<int32>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/retract_vote.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setPollAnswer', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['option_ids'] = 'vector<int32>'}, nil, {['option_ids'] = {}}, nil)
