--- Get interactions for a story posted by the current account.
-- @module titogramlua.methods.userbot.get_story_views
-- @usage client:get_story_views(story_id, {limit = 100})
return function(self, story_id, opts)
    assert(type(story_id) == 'number', 'story_id must be a number')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    local params = {
        story_id = story_id,
        query = opts.query or '',
        only_contacts = opts.only_contacts == true,
        prefer_forwards = opts.prefer_forwards == true,
        prefer_with_reaction = opts.prefer_with_reaction == true,
        offset = opts.offset or '',
        limit = opts.limit or 100,
    }
    assert(type(params.limit) == 'number' and params.limit > 0, 'limit must be a positive number')
    return self:send('getStoryInteractions', params)
end
