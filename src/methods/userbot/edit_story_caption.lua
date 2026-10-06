--- Edit a story caption using TDLib's editStory method.
-- @module titogramlua.methods.userbot.edit_story_caption
-- @usage client:edit_story_caption(poster_chat_id, story_id, caption, content)
-- @param content the complete TDLib InputStoryContent (TDLib requires it for editStory)
return function(self, poster_chat_id, story_id, caption, content, opts)
    assert(type(caption) == 'string', 'caption must be a string')
    assert(type(content) == 'table' and content['@type'],
        'content must be the current TDLib InputStoryContent object')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    return self:edit_story(poster_chat_id, story_id, content, {
        caption = caption,
        entities = opts.entities,
        areas = opts.areas,
    })
end
