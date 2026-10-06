--- Check whether the current account can post a story as a chat.
-- @module titogramlua.methods.userbot.can_post_stories
-- @usage client:can_post_stories(chat_id)
return function(self, chat_id)
    assert(chat_id ~= nil, 'chat_id is required')
    return self:send('canPostStory', {chat_id = chat_id})
end
