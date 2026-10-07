--- Search contacts through TDLib searchContacts.
-- @module titogramlua.methods.userbot.search_contacts
-- @usage client:search_contacts(params, callback)
-- @param params table with TDLib fields: query:string, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/contacts/search_contacts.py
local support = require('titogramlua.methods.userbot._support')
return support.method('searchContacts', {['query'] = 'string', ['limit'] = 'int32'}, nil, nil, nil)
