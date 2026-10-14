--- Set contact note through TDLib setUserNote.
-- @module titogramlua.methods.userbot.set_contact_note
-- @usage client:set_contact_note(params, callback)
-- @param params table with TDLib fields: user_id:int53, note:formattedText
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setUserNote', {['user_id'] = 'int53', ['note'] = 'formattedText'}, nil, nil, nil)
