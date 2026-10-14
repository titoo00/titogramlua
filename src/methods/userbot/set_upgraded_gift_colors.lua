--- Set upgraded gift colors through TDLib setUpgradedGiftColors.
-- @module titogramlua.methods.userbot.set_upgraded_gift_colors
-- @usage client:set_upgraded_gift_colors(params, callback)
-- @param params table with TDLib fields: upgraded_gift_colors_id:int64
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setUpgradedGiftColors', {['upgraded_gift_colors_id'] = 'int64'}, nil, nil, nil)
