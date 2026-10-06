--- Set pinned story IDs for a chat (requires the appropriate chat rights).
-- @module titogramlua.methods.userbot.pin_chat_stories
-- @usage client:pin_chat_stories(chat_id, {1, 2})
return function(self, chat_id, story_ids)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(type(story_ids) == 'table', 'story_ids must be a table')
    return self:send('setChatPinnedStories', {chat_id = chat_id, story_ids = story_ids})
end
