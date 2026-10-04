--- Delete a story when TDLib reports that it can be deleted.
-- @module titogramlua.methods.userbot.delete_story
-- @usage client:delete_story(poster_chat_id, story_id)
return function(self, poster_chat_id, story_id)
    assert(poster_chat_id ~= nil, 'poster_chat_id is required')
    assert(story_id ~= nil, 'story_id is required')
    return self:send('deleteStory', {
        story_poster_chat_id = poster_chat_id,
        story_id = story_id
    })
end
