--- Get contacts count through TDLib getContacts.
-- @module titogramlua.methods.userbot.get_contacts_count
-- @usage client:get_contacts_count(params, callback)
-- @param params table with TDLib fields: none
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getContacts', {}, nil, nil, function(result) return #(result.user_ids or {}) end)
