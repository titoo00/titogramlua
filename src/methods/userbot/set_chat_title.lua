--- Set chat title through TDLib setChatTitle.
-- @module titogramlua.methods.userbot.set_chat_title
-- @usage client:set_chat_title(params, callback)
-- @param params table with TDLib fields: chat_id:int53, title:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatTitle', {['chat_id'] = 'int53', ['title'] = 'string'}, nil, nil, nil)
