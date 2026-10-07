--- Add checklist tasks through TDLib addChecklistTasks.
-- @module titogramlua.methods.userbot.add_checklist_tasks
-- @usage client:add_checklist_tasks(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, tasks:vector<inputChecklistTask>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/add_checklist_tasks.py
local support = require('titogramlua.methods.userbot._support')
return support.method('addChecklistTasks', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['tasks'] = 'vector<inputChecklistTask>'}, nil, nil, nil)
