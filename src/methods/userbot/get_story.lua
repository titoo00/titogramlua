--- Get a story by the poster chat and story identifiers.
-- @module titogramlua.methods.userbot.get_story
-- @usage client:get_story(poster_chat_id, story_id)
return function(self, poster_chat_id, story_id, only_local)
    assert(poster_chat_id ~= nil, 'poster_chat_id is required')
    assert(story_id ~= nil, 'story_id is required')
    return self:send('getStory', {
        story_poster_chat_id = poster_chat_id,
        story_id = story_id,
        only_local = only_local == true
    })
end
