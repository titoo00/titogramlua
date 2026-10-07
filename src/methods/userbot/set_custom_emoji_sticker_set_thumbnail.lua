--- Set custom emoji sticker set thumbnail through TDLib setCustomEmojiStickerSetThumbnail.
-- @module titogramlua.methods.userbot.set_custom_emoji_sticker_set_thumbnail
-- @usage client:set_custom_emoji_sticker_set_thumbnail(params, callback)
-- @param params table with TDLib fields: name:string, custom_emoji_id:int64
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/stickers/set_custom_emoji_sticker_set_thumbnail.py
local support = require('titogramlua.methods.userbot._support')
return support.method('setCustomEmojiStickerSetThumbnail', {['name'] = 'string', ['custom_emoji_id'] = 'int64'}, nil, nil, nil)
