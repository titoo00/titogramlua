--- Mark chat unread using TDLib toggleChatIsMarkedAsUnread.
-- @module titogramlua.methods.userbot.mark_chat_unread
-- @usage client:mark_chat_unread(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: chat_id:int53, is_marked_as_unread:Bool
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('toggleChatIsMarkedAsUnread', {['chat_id'] = 'int53', ['is_marked_as_unread'] = 'Bool'}, nil, {['is_marked_as_unread'] = true})
