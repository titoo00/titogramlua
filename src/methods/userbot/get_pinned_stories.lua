--- Get stories posted to a chat page; pinned stories are returned first.
-- @module titogramlua.methods.userbot.get_pinned_stories
-- @usage client:get_pinned_stories(chat_id, 0, 20)
return function(self, chat_id, from_story_id, limit)
    assert(chat_id ~= nil, 'chat_id is required')
    from_story_id = from_story_id or 0
    limit = limit or 20
    assert(type(limit) == 'number' and limit > 0, 'limit must be a positive number')
    return self:send('getChatPostedToChatPageStories', {
        chat_id = chat_id,
        from_story_id = from_story_id,
        limit = math.floor(limit),
    })
end
