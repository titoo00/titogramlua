--- Create channel using TDLib createNewSupergroupChat.
-- @module titogramlua.methods.userbot.create_channel
-- @usage client:create_channel(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: title:string, is_forum:Bool, is_channel:Bool, description:string, location:chatLocation, message_auto_delete_time:int32, for_import:Bool
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('createNewSupergroupChat', {['title'] = 'string', ['is_forum'] = 'Bool', ['is_channel'] = 'Bool', ['description'] = 'string', ['location'] = 'chatLocation', ['message_auto_delete_time'] = 'int32', ['for_import'] = 'Bool'}, {['description'] = '', ['message_auto_delete_time'] = 0}, {['is_channel'] = true, ['is_forum'] = false, ['for_import'] = false})
