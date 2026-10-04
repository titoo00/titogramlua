--- Edit a text message sent by the signed-in user.
-- @module titogramlua.methods.userbot.edit_message_text
-- @usage client:edit_message_text(chat_id, message_id, 'Updated text')
return function(self, chat_id, message_id, text, opts)
    assert(chat_id ~= nil, 'chat_id is required')
    assert(message_id ~= nil, 'message_id is required')
    assert(type(text) == 'string', 'text must be a string')
    opts = opts or {}
    assert(type(opts) == 'table', 'opts must be a table')

    return self:send('editMessageText', {
        chat_id = chat_id,
        message_id = message_id,
        reply_markup = opts.reply_markup,
        input_message_content = {
            ['@type'] = 'inputMessageText',
            text = {['@type'] = 'formattedText', text = text, entities = opts.entities or {}},
            link_preview_options = opts.link_preview_options,
            clear_draft = false
        }
    })
end
