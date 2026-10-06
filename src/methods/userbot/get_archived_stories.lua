--- Get a page of archived stories for a chat (admin rights may be required).
-- @module titogramlua.methods.userbot.get_archived_stories
-- @usage client:get_archived_stories(chat_id, 0, 20)
return function(self, chat_id, from_story_id, limit)
    assert(chat_id ~= nil, 'chat_id is required')
    from_story_id = from_story_id or 0
    limit = limit or 20
    assert(type(from_story_id) == 'number', 'from_story_id must be a number')
    assert(type(limit) == 'number' and limit > 0, 'limit must be a positive number')
    return self:send('getChatArchivedStories', {
        chat_id = chat_id,
        from_story_id = math.floor(from_story_id),
        limit = math.floor(limit),
    })
end
