--- Send a text message as the signed-in user.
-- @module titogramlua.methods.userbot.send_message
-- @usage client:send_message(chat_id, 'Hello from my user account')
-- @usage client:send_message(chat_id, 'Hello', {topic_id = topic_id})
return function(self, chat_id, text, opts)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(type(text) == 'string', 'text must be a string')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')

    local content = {
        ['@type'] = 'inputMessageText',
        text = {['@type'] = 'formattedText', text = text, entities = opts.entities or {}},
        clear_draft = opts.clear_draft == true
    }
    if opts.link_preview_options then
        content.link_preview_options = opts.link_preview_options
    end

    return self:send('sendMessage', {
        chat_id = chat_id,
        topic_id = opts.topic_id,
        reply_to = opts.reply_to,
        options = opts.send_options,
        reply_markup = opts.reply_markup,
        input_message_content = content
    })
end
