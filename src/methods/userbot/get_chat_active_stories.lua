--- Get currently active stories posted by a chat.
-- @module titogramlua.methods.userbot.get_chat_active_stories
-- @usage client:get_chat_active_stories(chat_id)
return function(self, chat_id)
    assert(chat_id ~= nil, 'chat_id is required')
    return self:send('getChatActiveStories', {chat_id = chat_id})
end
