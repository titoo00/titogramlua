--- Edit a story when TDLib reports that it can be edited.
-- @module titogramlua.methods.userbot.edit_story
-- @usage client:edit_story(poster_chat_id, story_id, input_story_content, {caption = 'Updated caption'})
return function(self, poster_chat_id, story_id, content, opts)
    assert(poster_chat_id ~= nil, 'poster_chat_id is required')
    assert(story_id ~= nil, 'story_id is required')
    assert(type(content) == 'table' and content['@type'], 'content must be an inputStoryContentPhoto or inputStoryContentVideo object')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')

    local caption = opts.caption
    if type(caption) == 'string' then
        caption = {['@type'] = 'formattedText', text = caption, entities = opts.entities or {}}
    end
    local areas = opts.areas
    if type(areas) == 'table' and not areas['@type'] then
        areas = {['@type'] = 'inputStoryAreas', areas = areas}
    end

    return self:send('editStory', {
        story_poster_chat_id = poster_chat_id,
        story_id = story_id,
        content = content,
        areas = areas,
        caption = caption
    })
end
