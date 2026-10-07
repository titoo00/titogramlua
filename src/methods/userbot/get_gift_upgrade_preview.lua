--- Get gift upgrade preview through TDLib getGiftUpgradePreview.
-- @module titogramlua.methods.userbot.get_gift_upgrade_preview
-- @usage client:get_gift_upgrade_preview(params, callback)
-- @param params table with TDLib fields: regular_gift_id:int64
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/payments/get_gift_upgrade_preview.py
local support = require('titogramlua.methods.userbot._support')
return support.method('getGiftUpgradePreview', {['regular_gift_id'] = 'int64'}, nil, nil, nil)
