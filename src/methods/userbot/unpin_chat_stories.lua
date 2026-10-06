--- Remove pinned stories from a chat.
-- @module titogramlua.methods.userbot.unpin_chat_stories
-- @usage client:unpin_chat_stories(chat_id, story_ids)
return function(self, chat_id, story_ids)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(type(story_ids) == 'table', 'story_ids must be a table (use {} to unpin all)')
    return self:send('setChatPinnedStories', {chat_id = chat_id, story_ids = story_ids})
end
