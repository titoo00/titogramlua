--- Delete one or more stories posted by a chat.
-- @module titogramlua.methods.userbot.delete_stories
-- @usage client:delete_stories(poster_chat_id, {1, 2})
return function(self, poster_chat_id, story_ids)
    assert(poster_chat_id ~= nil, 'poster_chat_id is required')
    assert(story_ids ~= nil, 'story_ids is required')
    if type(story_ids) ~= 'table' then story_ids = {story_ids} end
    local requests = {}
    for _, story_id in ipairs(story_ids) do
        requests[#requests + 1] = self:delete_story(poster_chat_id, story_id)
    end
    return requests
end
