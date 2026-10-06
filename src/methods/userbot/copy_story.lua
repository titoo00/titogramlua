--- Copy supplied story content into a new story without a repost reference.
-- @module titogramlua.methods.userbot.copy_story
-- @usage client:copy_story(chat_id, content, from_story_full_id, opts)
return function(self, chat_id, content, from_story_full_id, opts)
    assert(from_story_full_id == nil or type(from_story_full_id) == 'table',
        'the third argument must be an options table, storyFullId, or nil')
    -- Keep the existing four-argument form; the three-argument form accepts opts.
    if opts == nil and (from_story_full_id == nil or from_story_full_id['@type'] ~= 'storyFullId') then
        opts = from_story_full_id
    end
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    local post_opts = {}
    for key, value in pairs(opts) do post_opts[key] = value end
    post_opts.from_story_full_id = nil
    return self:upload_story(chat_id, content, post_opts)
end
