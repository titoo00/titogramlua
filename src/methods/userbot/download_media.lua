--- Download media through TDLib downloadFile.
-- @module titogramlua.methods.userbot.download_media
-- @usage client:download_media(params, callback)
-- @param params table with TDLib fields: file_id:int32, priority:int32, offset:int53, limit:int53, synchronous:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('downloadFile', {['file_id'] = 'int32', ['priority'] = 'int32', ['offset'] = 'int53', ['limit'] = 'int53', ['synchronous'] = 'Bool'}, {['priority'] = 16, ['offset'] = 0, ['limit'] = 0, ['synchronous'] = true}, nil, nil)
