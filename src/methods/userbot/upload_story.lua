--- Post a photo or video story through TDLib.
-- @module titogramlua.methods.userbot.upload_story
-- @usage client:upload_story(saved_messages_chat_id, {['@type'] = 'inputStoryContentPhoto', photo = {['@type'] = 'inputFileLocal', path = './story.jpg'}, added_sticker_file_ids = {}}, {privacy_settings = {['@type'] = 'storyPrivacySettingsContacts', except_user_ids = {}}})
-- The current user's Saved Messages chat identifier is used to post a personal story.
return function(self, chat_id, content, opts)
    assert(chat_id ~= nil, 'chat_id is required (use the Saved Messages chat for a personal story)')
    assert(type(content) == 'table' and content['@type'], 'content must be an inputStoryContentPhoto or inputStoryContentVideo object')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')
    assert(type(opts.privacy_settings) == 'table' and opts.privacy_settings['@type'],
        'opts.privacy_settings must explicitly select TDLib story privacy settings')

    local caption = opts.caption
    if type(caption) == 'string' then
        caption = {['@type'] = 'formattedText', text = caption, entities = opts.entities or {}}
    end
    local areas = opts.areas
    if type(areas) == 'table' and not areas['@type'] then
        areas = {['@type'] = 'inputStoryAreas', areas = areas}
    end

    return self:send('postStory', {
        chat_id = chat_id,
        content = content,
        areas = areas,
        caption = caption,
        privacy_settings = opts.privacy_settings,
        album_ids = opts.album_ids or {},
        active_period = opts.active_period or 86400,
        from_story_full_id = opts.from_story_full_id,
        is_posted_to_chat_page = opts.is_posted_to_chat_page == true,
        protect_content = opts.protect_content == true
    })
end
