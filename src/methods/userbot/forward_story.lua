--- Repost a story as a new story, preserving its full TDLib story ID.
-- @module titogramlua.methods.userbot.forward_story
-- @usage client:forward_story(chat_id, content, from_story_full_id, opts)
return function(self, chat_id, content, from_story_full_id, opts)
    assert(type(from_story_full_id) == 'table' and from_story_full_id['@type'] == 'storyFullId',
        'from_story_full_id must be a TDLib storyFullId object')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    local post_opts = {}
    for key, value in pairs(opts) do post_opts[key] = value end
    post_opts.from_story_full_id = from_story_full_id
    return self:upload_story(chat_id, content, post_opts)
end
