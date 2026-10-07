--- Get custom emoji stickers through TDLib getCustomEmojiStickers.
-- @module titogramlua.methods.userbot.get_custom_emoji_stickers
-- @usage client:get_custom_emoji_stickers(params, callback)
-- @param params table with TDLib fields: custom_emoji_ids:vector<int64>
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/get_custom_emoji_stickers.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getCustomEmojiStickers', {['custom_emoji_ids'] = 'vector<int64>'}, nil, nil, nil)
