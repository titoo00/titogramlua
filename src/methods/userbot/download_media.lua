--- Download media through TDLib downloadFile.
-- @module titogramlua.methods.userbot.download_media
-- @usage client:download_media(params, callback)
-- @param params table with TDLib fields: file_id:int32, priority:int32, offset:int53, limit:int53, synchronous:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/download_media.py
local support = require('titogramlua.methods.userbot._support')
return support.method('downloadFile', {['file_id'] = 'int32', ['priority'] = 'int32', ['offset'] = 'int53', ['limit'] = 'int53', ['synchronous'] = 'Bool'}, {['priority'] = 16, ['offset'] = 0, ['limit'] = 0, ['synchronous'] = true}, nil, nil)
