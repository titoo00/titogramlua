--- Set chat accent color through TDLib setChatAccentColor.
-- @module titogramlua.methods.userbot.set_chat_accent_color
-- @usage client:set_chat_accent_color(params, callback)
-- @param params table with TDLib fields: chat_id:int53, accent_color_id:int32, background_custom_emoji_id:int64
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/chats/set_chat_accent_color.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatAccentColor', {['chat_id'] = 'int53', ['accent_color_id'] = 'int32', ['background_custom_emoji_id'] = 'int64'}, nil, nil, nil)
