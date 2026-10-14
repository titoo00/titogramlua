--- Update chat notifications through TDLib setChatNotificationSettings.
-- @module titogramlua.methods.userbot.update_chat_notifications
-- @usage client:update_chat_notifications(params, callback)
-- @param params table with TDLib fields: chat_id:int53, notification_settings:chatNotificationSettings
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setChatNotificationSettings', {['chat_id'] = 'int53', ['notification_settings'] = 'chatNotificationSettings'}, nil, nil, nil)
