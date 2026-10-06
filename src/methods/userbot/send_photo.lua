--- Send a photo as the signed-in user.
-- @module titogramlua.methods.userbot.send_photo
-- @usage client:send_photo(chat_id, {['@type'] = 'inputFileLocal', path = './photo.jpg'}, {caption = 'Hello'})
return function(self, chat_id, photo, opts)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(type(photo) == 'table' and photo['@type'], 'photo must be a TDLib InputFile or inputPhoto object')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')

    local caption = opts.caption or ''
    if type(caption) == 'string' then
        caption = {['@type'] = 'formattedText', text = caption, entities = opts.entities or {}}
    end
    local content = {
        ['@type'] = 'inputMessagePhoto',
        photo = photo['@type'] == 'inputPhoto' and photo or {
            ['@type'] = 'inputPhoto',
            photo = photo,
            thumbnail = opts.thumbnail,
            video = opts.video,
            added_sticker_file_ids = opts.added_sticker_file_ids or {},
            width = opts.width or 0,
            height = opts.height or 0,
        },
        caption = caption,
        show_caption_above_media = opts.show_caption_above_media == true,
        has_spoiler = opts.has_spoiler == true
    }
    if opts.self_destruct_type then content.self_destruct_type = opts.self_destruct_type end

    return self:send('sendMessage', {
        chat_id = chat_id,
        topic_id = opts.topic_id,
        reply_to = opts.reply_to,
        options = opts.send_options,
        input_message_content = content
    })
end
