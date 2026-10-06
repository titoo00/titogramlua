--- Mark one or more stories as viewed by opening them in TDLib.
-- @module titogramlua.methods.userbot.view_stories
-- @usage client:view_stories(poster_chat_id, story_ids)
return function(self, poster_chat_id, story_ids)
    assert(poster_chat_id ~= nil, 'poster_chat_id is required')
    assert(story_ids ~= nil, 'story_ids is required')
    if type(story_ids) ~= 'table' then story_ids = {story_ids} end
    local requests = {}
    for _, story_id in ipairs(story_ids) do
        assert(type(story_id) == 'number', 'story_ids must contain numbers')
        requests[#requests + 1] = self:send('openStory', {
            story_poster_chat_id = poster_chat_id,
            story_id = story_id,
        })
    end
    return requests
end
