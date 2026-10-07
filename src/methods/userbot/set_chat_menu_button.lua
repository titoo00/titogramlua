--- Set chat menu button through TDLib setMenuButton.
-- @module titogramlua.methods.userbot.set_chat_menu_button
-- @usage client:set_chat_menu_button(params, callback)
-- @param params table with TDLib fields: user_id:int53, menu_button:botMenuButton
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/bots/set_chat_menu_button.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setMenuButton', {['user_id'] = 'int53', ['menu_button'] = 'botMenuButton'}, nil, nil, nil)
