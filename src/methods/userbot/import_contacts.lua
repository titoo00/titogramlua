--- Import contacts through TDLib importContacts.
-- @module titogramlua.methods.userbot.import_contacts
-- @usage client:import_contacts(params, callback)
-- @param params table with TDLib fields: contacts:vector<importedContact>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/contacts/import_contacts.py
local support = require('titogramlua.methods.userbot._support')
return support.method('importContacts', {['contacts'] = 'vector<importedContact>'}, nil, nil, nil)
