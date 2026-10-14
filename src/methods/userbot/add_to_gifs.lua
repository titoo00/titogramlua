--- Add to gifs through TDLib addSavedAnimation.
-- @module titogramlua.methods.userbot.add_to_gifs
-- @usage client:add_to_gifs(params, callback)
-- @param params table with TDLib fields: animation:InputFile
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('addSavedAnimation', {['animation'] = 'InputFile'}, nil, nil, nil)
