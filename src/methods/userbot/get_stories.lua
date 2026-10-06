--- Get one story or a list of story IDs from a poster chat.
-- @module titogramlua.methods.userbot.get_stories
-- @usage client:get_stories(poster_chat_id, story_ids)
return function(self, poster_chat_id, story_ids, only_local)
    assert(poster_chat_id ~= nil, 'poster_chat_id is required')
    assert(story_ids ~= nil, 'story_ids is required')
    if type(story_ids) ~= 'table' then
        return self:get_story(poster_chat_id, story_ids, only_local)
    end
    local requests = {}
    for _, story_id in ipairs(story_ids) do
        assert(type(story_id) == 'number', 'story_ids must contain numbers')
        requests[#requests + 1] = self:get_story(poster_chat_id, story_id, only_local)
    end
    return requests
end
