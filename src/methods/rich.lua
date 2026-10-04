--- rich message API methods (Bot API 10.3).
-- @module titogramlua.methods.rich
return function(api)
    local json = require('dkjson')
    local config = require('titogramlua.config')

    --- send a rich formatted message to a chat.
    -- a rich message is described with HTML or markdown via an InputRichMessage object;
    -- see api.input_rich_message for a builder.
    -- @param chat_id number|string unique identifier for the target chat or username of the target bot/supergroup/channel
    -- @param rich_message table|string an InputRichMessage object describing the message to send
    -- @param opts table optional parameters
    -- @param opts.business_connection_id string unique identifier of the business connection
    -- @param opts.message_thread_id number unique identifier for the target message thread (topic) of a forum
    -- @param opts.direct_messages_topic_id number identifier of the direct messages topic to send to
    -- @param opts.disable_notification boolean send the message silently
    -- @param opts.protect_content boolean protect the contents of the sent message from forwarding and saving
    -- @param opts.allow_paid_broadcast boolean allow up to 1000 messages per second for a fee
    -- @param opts.message_effect_id string unique identifier of the message effect to add; private chats only
    -- @param opts.suggested_post_parameters table parameters of the suggested post to send
    -- @param opts.reply_parameters table description of the message to reply to
    -- @param opts.reply_markup table additional interface options
    -- @return table,number the response object and HTTP status
    function api.send_rich_message(chat_id, rich_message, opts)
        opts = opts or {}
        rich_message = type(rich_message) == 'table' and json.encode(rich_message) or rich_message
        local suggested_post_parameters = opts.suggested_post_parameters
        suggested_post_parameters = type(suggested_post_parameters) == 'table' and json.encode(suggested_post_parameters) or suggested_post_parameters
        local reply_parameters = opts.reply_parameters
        reply_parameters = type(reply_parameters) == 'table' and json.encode(reply_parameters) or reply_parameters
        local reply_markup = opts.reply_markup
        reply_markup = type(reply_markup) == 'table' and json.encode(reply_markup) or reply_markup
        local success, res = api.request(config.endpoint .. api.token .. '/sendRichMessage', {
            ['business_connection_id'] = opts.business_connection_id,
            ['chat_id'] = chat_id,
            ['message_thread_id'] = opts.message_thread_id,
            ['direct_messages_topic_id'] = opts.direct_messages_topic_id,
            ['ephemeral_message_parameters'] = type(opts.ephemeral_message_parameters) == 'table' and json.encode(opts.ephemeral_message_parameters) or opts.ephemeral_message_parameters,
            ['rich_message'] = rich_message,
            ['disable_notification'] = opts.disable_notification,
            ['protect_content'] = opts.protect_content,
            ['allow_paid_broadcast'] = opts.allow_paid_broadcast,
            ['message_effect_id'] = opts.message_effect_id,
            ['suggested_post_parameters'] = suggested_post_parameters,
            ['reply_parameters'] = reply_parameters,
            ['reply_markup'] = reply_markup
        })
        return success, res
    end

    --- send a rich message containing text and a row of buttons.
    -- @param chat_id number|string unique identifier for the target chat
    -- @param text string text to display above the buttons
    -- @param buttons table array of rich message buttons
    -- @param opts table optional sendRichMessage parameters
    -- @return table,number the response object and HTTP status
    function api.send_buttons(chat_id, text, buttons, opts)
        local rich_message = {
            blocks = {
                { type = 'paragraph', text = text },
                { type = 'buttons', align = 'center', buttons = buttons }
            }
        }
        return api.send_rich_message(chat_id, rich_message, opts)
    end

    --- send up to ten photos in a rich message slideshow.
    -- @param chat_id number|string unique identifier for the target chat
    -- @param photos table array of photo file IDs or URLs
    -- @param caption string|nil optional slideshow caption
    -- @param opts table optional sendRichMessage parameters
    -- @return table,number the response object and HTTP status
    function api.send_slideshow(chat_id, photos, caption, opts)
        local slides = {}
        for i = 1, math.min(#photos, 10) do
            slides[i] = {
                type = 'photo',
                photo = { type = 'photo', media = photos[i] }
            }
        end

        local rich_message = {
            blocks = {
                {
                    type = 'slideshow',
                    blocks = slides,
                    caption = { text = caption or '' }
                }
            }
        }
        return api.send_rich_message(chat_id, rich_message, opts)
    end

    --- stream a partial rich message to a private chat as a draft.
    -- repeated calls with the same draft_id animate the changes; useful for streaming
    -- AI-generated replies. a non-zero draft_id is required.
    -- @param chat_id number unique identifier for the target private chat
    -- @param draft_id number unique identifier of the message draft; must be non-zero
    -- @param rich_message table|string an InputRichMessage object describing the partial message
    -- @param opts table optional parameters
    -- @param opts.message_thread_id number unique identifier for the target message thread
    -- @return table,number the response object and HTTP status
    function api.send_rich_message_draft(chat_id, draft_id, rich_message, opts)
        opts = opts or {}
        rich_message = type(rich_message) == 'table' and json.encode(rich_message) or rich_message
        local success, res = api.request(config.endpoint .. api.token .. '/sendRichMessageDraft', {
            ['chat_id'] = chat_id,
            ['message_thread_id'] = opts.message_thread_id,
            ['draft_id'] = draft_id,
            ['rich_message'] = rich_message,
            ['can_stop'] = opts.can_stop,
            ['keep_on_stop'] = opts.keep_on_stop
        })
        return success, res
    end

    --- stream a partial text message to a private chat as a draft.
    -- @param chat_id number unique identifier for the target private chat
    -- @param draft_id number unique, non-zero identifier of the draft
    -- @param text string partial text; empty string displays a thinking placeholder
    -- @param opts table optional parameters: message_thread_id, parse_mode, entities, can_stop, keep_on_stop
    function api.send_message_draft(chat_id, draft_id, text, opts)
        opts = opts or {}
        local parse_mode = opts.parse_mode
        parse_mode = (type(parse_mode) == 'boolean' and parse_mode == true) and 'MarkdownV2' or parse_mode
        local success, res = api.request(config.endpoint .. api.token .. '/sendMessageDraft', {
            ['chat_id'] = chat_id,
            ['message_thread_id'] = opts.message_thread_id,
            ['draft_id'] = draft_id,
            ['text'] = text,
            ['parse_mode'] = parse_mode,
            ['entities'] = type(opts.entities) == 'table' and json.encode(opts.entities) or opts.entities,
            ['can_stop'] = opts.can_stop,
            ['keep_on_stop'] = opts.keep_on_stop
        })
        return success, res
    end

end
