--- Delete contacts through TDLib removeContacts.
-- @module titogramlua.methods.userbot.delete_contacts
-- @usage client:delete_contacts(params, callback)
-- @param params table with TDLib fields: user_ids:vector<int53>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/contacts/delete_contacts.py
local support = require('titogramlua.methods.userbot._support')
return support.method('removeContacts', {['user_ids'] = 'vector<int53>'}, nil, nil, nil)
