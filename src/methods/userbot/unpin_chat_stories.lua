--- Remove selected story IDs from the current pinned list, or clear all pins.
-- @module titogramlua.methods.userbot.unpin_chat_stories
-- @usage client:unpin_chat_stories(chat_id, story_ids)
-- Pass nil or an empty list to clear all pins. For selected IDs, returns the
-- initial read request ID; the subsequent write response arrives via on_update.
return function(self, chat_id, story_ids)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(story_ids == nil or type(story_ids) == 'table', 'story_ids must be an array or nil')
    if story_ids == nil or next(story_ids) == nil then
        return self:send('setChatPinnedStories', {chat_id = chat_id, story_ids = {}})
    end
    local remove = {}
    for _, id in ipairs(story_ids) do
        assert(type(id) == 'number' and id > 0 and id == math.floor(id), 'story IDs must be positive integers')
        remove[id] = true
    end
    assert(next(remove), 'story_ids must be a non-empty array')
    return self:request('getChatPostedToChatPageStories', {
        chat_id = chat_id, from_story_id = 0, limit = 1,
    }, function(result, err, client)
        if err then return end
        if type(result.pinned_story_ids) ~= 'table' then
            if client.on_error then client.on_error('TDLib did not return pinned_story_ids', client) end
            return
        end
        local remaining = {}
        for _, id in ipairs(result.pinned_story_ids) do
            if not remove[id] then remaining[#remaining + 1] = id end
        end
        client:send('setChatPinnedStories', {chat_id = chat_id, story_ids = remaining})
    end)
end
