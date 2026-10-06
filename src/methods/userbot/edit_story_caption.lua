--- Edit a story caption using TDLib's editStory method.
-- @module titogramlua.methods.userbot.edit_story_caption
-- @usage client:edit_story_caption(poster_chat_id, story_id, caption, content)
-- @param content optional TDLib InputStoryContent; nil preserves the media
return function(self, poster_chat_id, story_id, caption, content, opts)
    assert(type(caption) == 'string' or (type(caption) == 'table' and caption['@type'] == 'formattedText'),
        'caption must be a string or TDLib formattedText object')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    return self:edit_story(poster_chat_id, story_id, content, {
        caption = caption,
        entities = opts.entities,
        areas = opts.areas,
    })
end
