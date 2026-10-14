--- Set sticker position in set through TDLib setStickerPositionInSet.
-- @module titogramlua.methods.userbot.set_sticker_position_in_set
-- @usage client:set_sticker_position_in_set(params, callback)
-- @param params table with TDLib fields: sticker:InputFile, position:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setStickerPositionInSet', {['sticker'] = 'InputFile', ['position'] = 'int32'}, nil, nil, nil)
