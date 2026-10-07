--- Add contact through TDLib addContact.
-- @module titogramlua.methods.userbot.add_contact
-- @usage client:add_contact(params, callback)
-- @param params table with TDLib fields: user_id:int53, contact:importedContact, share_phone_number:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/contacts/add_contact.py
local support = require('titogramlua.methods.userbot._support')
return support.method('addContact', {['user_id'] = 'int53', ['contact'] = 'importedContact', ['share_phone_number'] = 'Bool'}, nil, nil, nil)
