--- Open a story so TDLib records it as viewed.
-- @module titogramlua.methods.userbot.read_chat_stories
-- @usage client:read_chat_stories(poster_chat_id, story_id)
return function(self, poster_chat_id, story_id)
    assert(poster_chat_id ~= nil, 'poster_chat_id is required')
    assert(type(story_id) == 'number', 'story_id must be a number')
    return self:send('openStory', {
        story_poster_chat_id = poster_chat_id,
        story_id = story_id,
    })
end
