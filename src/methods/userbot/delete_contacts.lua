--- Delete contacts through TDLib removeContacts.
-- @module titogramlua.methods.userbot.delete_contacts
-- @usage client:delete_contacts(params, callback)
-- @param params table with TDLib fields: user_ids:vector<int53>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('removeContacts', {['user_ids'] = 'vector<int53>'}, nil, nil, nil)
