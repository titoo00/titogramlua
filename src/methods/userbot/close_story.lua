--- Close a story previously opened with read_chat_stories or view_stories.
-- @module titogramlua.methods.userbot.close_story
-- @usage client:close_story(poster_chat_id, story_id)
return function(self, poster_chat_id, story_id)
    assert(poster_chat_id ~= nil, 'poster_chat_id is required')
    assert(type(story_id) == 'number' and story_id > 0 and story_id == math.floor(story_id),
        'story_id must be a positive integer')
    return self:send('closeStory', {story_poster_chat_id = poster_chat_id, story_id = story_id})
end
