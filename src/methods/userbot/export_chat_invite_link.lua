--- Export chat invite link through TDLib replacePrimaryChatInviteLink.
-- @module titogramlua.methods.userbot.export_chat_invite_link
-- @usage client:export_chat_invite_link(params, callback)
-- @param params table with TDLib fields: chat_id:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('replacePrimaryChatInviteLink', {['chat_id'] = 'int53'}, nil, nil, nil)
