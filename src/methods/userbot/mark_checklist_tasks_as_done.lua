--- Mark checklist tasks as done through TDLib markChecklistTasksAsDone.
-- @module titogramlua.methods.userbot.mark_checklist_tasks_as_done
-- @usage client:mark_checklist_tasks_as_done(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, marked_as_done_task_ids:vector<int32>, marked_as_not_done_task_ids:vector<int32>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('markChecklistTasksAsDone', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['marked_as_done_task_ids'] = 'vector<int32>', ['marked_as_not_done_task_ids'] = 'vector<int32>'}, nil, nil, nil)
