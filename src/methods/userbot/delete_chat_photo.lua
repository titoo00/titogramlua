--- Delete chat photo through TDLib setChatPhoto.
-- @module titogramlua.methods.userbot.delete_chat_photo
-- @usage client:delete_chat_photo(params, callback)
-- @param params table with TDLib fields: chat_id:int53, photo:InputChatPhoto
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatPhoto', {['chat_id'] = 'int53', ['photo'] = 'InputChatPhoto'}, nil, nil, nil)
