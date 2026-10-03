# Builders and Constructors

## Inline Keyboard

Chainable builder for inline keyboards:

```lua
local kb = api.inline_keyboard()
    :row(api.row()
        :callback_data_button('Option A', 'opt_a')
        :callback_data_button('Option B', 'opt_b'))
    :row(api.row()
        :url_button('Visit Site', 'https://example.com'))

api.send_message(chat_id, 'Choose:', { reply_markup = kb })
```

### Row button methods

| Method | Description |
|---|---|
| `:callback_data_button(text, callback_data)` | Button that sends callback data |
| `:url_button(text, url)` | Button that opens a URL |
| `:switch_inline_query_button(text, query)` | Switch to inline query |
| `:switch_inline_query_current_chat_button(text, query)` | Inline query in current chat |
| `:pay_button(text, pay)` | Payment button |

### Standalone button constructors

```lua
api.url_button(text, url, encoded)
api.callback_data_button(text, callback_data, encoded)
api.switch_inline_query_button(text, query, encoded)
api.switch_inline_query_current_chat_button(text, query, encoded)
api.callback_game_button(text, callback_game, encoded)
api.pay_button(text, pay, encoded)
api.copy_text_button(text, copy_text)   -- button that copies copy_text to the clipboard
```

Pass `encoded = true` to get a JSON string instead of a table.

Two field objects used inside inline keyboard buttons:

```lua
api.web_app_info(url)              -- a WebAppInfo (button's web_app field)
api.login_url(url, opts)           -- a LoginUrl; opts: forward_text, bot_username, request_write_access
```

## Regular Keyboard

```lua
local kb = api.keyboard(true, true)  -- resize_keyboard, one_time_keyboard
    :row({'Button 1', 'Button 2'})
    :row({'Button 3'})

api.send_message(chat_id, 'Choose:', { reply_markup = kb })
```

### Reply keyboard request buttons

Button objects for a regular (reply) keyboard. Place them in a row instead of plain strings:

```lua
api.keyboard_button_request_users(text, request_id, opts)
    -- opts: user_is_bot, user_is_premium, max_quantity, request_name, request_username, request_photo
api.keyboard_button_request_chat(text, request_id, chat_is_channel, opts)
    -- opts: chat_is_forum, chat_has_username, chat_is_created, user_administrator_rights,
    --       bot_administrator_rights, bot_is_member, request_title, request_username, request_photo
api.keyboard_button_request_contact(text)
api.keyboard_button_request_location(text)
api.keyboard_button_request_poll(text, poll_type)   -- poll_type: 'quiz', 'regular', or nil
api.keyboard_button_web_app(text, url)
```

```lua
local kb = api.keyboard(true, true)
    :row({ api.keyboard_button_request_contact('Share contact') })
    :row({ api.keyboard_button_request_users('Pick users', 1, { max_quantity = 3 }) })
```

## Remove Keyboard

```lua
api.send_message(chat_id, 'Keyboard removed', {
    reply_markup = api.remove_keyboard()
})
```

## Inline Results

Chainable builder for inline query results:

```lua
local result = api.inline_result()
    :type('article')
    :id('1')
    :title('Example Article')
    :description('This is a description')
    :input_message_content(api.input_text_message_content('Article text', 'HTML'))
    :thumbnail_url('https://example.com/thumb.jpg')
    :thumbnail_width(100)
    :thumbnail_height(100)
```

### Available chain methods

`:type()`, `:id()`, `:title()`, `:description()`, `:url()`, `:hide_url()`,
`:input_message_content()`, `:reply_markup()`, `:thumbnail_url()`,
`:thumbnail_width()`, `:thumbnail_height()`, `:photo_url()`, `:photo_width()`,
`:photo_height()`, `:caption()`, `:gif_url()`, `:gif_width()`, `:gif_height()`,
`:mpeg4_url()`, `:mpeg4_width()`, `:mpeg4_height()`, `:video_url()`,
`:mime_type()`, `:video_width()`, `:video_height()`, `:video_duration()`,
`:audio_url()`, `:performer()`, `:audio_duration()`, `:voice_url()`,
`:voice_duration()`, `:document_url()`, `:latitude()`, `:longitude()`,
`:live_period()`, `:address()`, `:foursquare_id()`, `:phone_number()`,
`:first_name()`, `:last_name()`, `:game_short_name()`

## Input Message Content

```lua
api.input_text_message_content(message_text, parse_mode, link_preview_options, encoded)
api.input_location_message_content(latitude, longitude, encoded)
api.input_venue_message_content(latitude, longitude, title, address, foursquare_id, encoded)
api.input_contact_message_content(phone_number, first_name, last_name, encoded)
```

## Input Media

```lua
-- Standalone constructors (return media_table, file_table)
api.input_media_photo(media, caption, parse_mode)
api.input_media_video(media, thumbnail, caption, parse_mode, width, height, duration, supports_streaming)
api.input_media_animation(media, thumbnail, caption, parse_mode, width, height, duration)
api.input_media_audio(media, thumbnail, caption, parse_mode, duration, performer, title)
api.input_media_document(media, thumbnail, caption, parse_mode)

-- Bot API 10.x media types
api.input_media_sticker(media, emoji)
api.input_media_location(latitude, longitude, horizontal_accuracy)
api.input_media_venue(latitude, longitude, title, address, opts)
api.input_media_live_photo(media, photo, opts)
api.input_media_link(url)
api.input_paid_media_live_photo(media, photo)

-- Paid media (for send_paid_media)
api.input_paid_media_photo(media)
api.input_paid_media_video(media, opts)
    -- opts: thumbnail, cover, start_timestamp, width, height, duration, supports_streaming

-- Chainable builder
local media = api.input_media()
    :photo('photo_file_id', 'First photo')
    :photo('photo_file_id_2', 'Second photo')
    :video('video_file_id', 'A video', 1280, 720, 120)
```

## Input Poll Option

```lua
api.input_poll_option(text, opts)   -- opts: text_parse_mode, text_entities, media
```

## Input Checklist

```lua
api.input_checklist_task(id, text, opts)   -- opts: parse_mode, text_entities
api.input_checklist(title, tasks, opts)
    -- opts: parse_mode, title_entities, others_can_add_tasks, others_can_mark_tasks_as_done
```

```lua
local checklist = api.input_checklist('Shopping', {
    api.input_checklist_task(1, 'Milk'),
    api.input_checklist_task(2, 'Bread')
})
api.send_checklist(chat_id, checklist)
```

## Input Story Content

```lua
api.input_story_content_photo(photo)
api.input_story_content_video(video, opts)   -- opts: duration, cover_frame_timestamp, is_animation
```

## Input Profile Photo

```lua
api.input_profile_photo_static(photo)
api.input_profile_photo_animated(animation, opts)   -- opts: main_frame_timestamp
```

## Rich Message Builders (Bot API 10.1)

### Sending

Build an `InputRichMessage` (what you send) from HTML or Markdown — supply exactly one:

```lua
api.input_rich_message({ html = '<b>Hi</b>', is_rtl = false, skip_entity_detection = false })
api.input_rich_message({ markdown = '*Hi*' })

api.input_rich_message_content(rich_message)  -- wrap for inline/guest/web app results
api.link(url)                                 -- a Link object
```

Pass the result to `api.send_rich_message`, `api.send_rich_message_draft`, or `edit_message_text`'s `rich_message` opt (see [Methods](methods.md#rich-messages)).

### Received structure (RichText / RichBlock)

These model the parsed `message.rich_message` (a `RichMessage` of `RichBlock`s, whose text is `RichText`). A rich text's `text` argument may be a plain string, an array, or another rich text.

```lua
api.rich_message(blocks, is_rtl)

-- rich text
api.rich_text_bold(text)         api.rich_text_italic(text)
api.rich_text_underline(text)    api.rich_text_strikethrough(text)
api.rich_text_spoiler(text)      api.rich_text_subscript(text)
api.rich_text_superscript(text)  api.rich_text_marked(text)
api.rich_text_code(text)
api.rich_text_date_time(text, unix_time, date_time_format)
api.rich_text_text_mention(text, user)
api.rich_text_custom_emoji(custom_emoji_id, alternative_text)   -- no text field
api.rich_text_mathematical_expression(expression)               -- no text field
api.rich_text_url(text, url)
api.rich_text_email_address(text, email_address)
api.rich_text_phone_number(text, phone_number)
api.rich_text_bank_card_number(text, bank_card_number)
api.rich_text_mention(text, username)
api.rich_text_hashtag(text, hashtag)
api.rich_text_cashtag(text, cashtag)
api.rich_text_bot_command(text, bot_command)
api.rich_text_anchor(name)                                      -- no text field
api.rich_text_anchor_link(text, anchor_name)
api.rich_text_reference(text, name)
api.rich_text_reference_link(text, reference_name)

-- rich blocks
api.rich_block_paragraph(text)
api.rich_block_heading(text, size)                  -- size 1-6
api.rich_block_preformatted(text, language)
api.rich_block_footer(text)
api.rich_block_divider()
api.rich_block_mathematical_expression(expression)
api.rich_block_anchor(name)
api.rich_block_list(items)
api.rich_block_list_item(label, blocks, opts)       -- opts: has_checkbox, is_checked, value, type
api.rich_block_blockquote(blocks, credit)
api.rich_block_pullquote(text, credit)
api.rich_block_collage(blocks, caption)
api.rich_block_slideshow(blocks, caption)
api.rich_block_table(cells, opts)                   -- opts: is_bordered, is_striped, caption
api.rich_block_table_cell(text, opts)               -- opts: is_header, colspan, rowspan, align, valign
api.rich_block_details(summary, blocks, is_open)
api.rich_block_map(location, opts)                  -- opts: zoom, width, height, caption
api.rich_block_animation(animation, opts)           -- opts: has_spoiler, caption
api.rich_block_audio(audio, caption)
api.rich_block_photo(photo, opts)                   -- opts: has_spoiler, caption
api.rich_block_video(video, opts)                   -- opts: has_spoiler, caption
api.rich_block_voice_note(voice_note, caption)
api.rich_block_caption(text, credit)
api.rich_block_thinking(text)                       -- drafts only
```

## Prices

Chainable builder for payment prices:

```lua
local prices = api.prices()
    :labeled_price('Item', 500)
    :labeled_price('Shipping', 100)

api.send_invoice(chat_id, 'Order', 'Your order', 'payload', 'USD', prices)
```

## Shipping Options

```lua
local options = api.shipping_options()
    :shipping_option('standard', 'Standard', api.prices():labeled_price('Standard', 500))
    :shipping_option('express', 'Express', api.prices():labeled_price('Express', 1000))
```

## Type Constructors

### Chat Permissions

```lua
api.chat_permissions({
    can_send_messages = true,
    can_send_photos = true,
    can_send_videos = true,
    can_send_polls = true,
    can_change_info = false,
    can_invite_users = true,
    can_pin_messages = false,
    can_manage_topics = false
})
```

### Chat Administrator Rights

```lua
api.chat_administrator_rights({
    can_manage_chat = true,
    can_delete_messages = true,
    can_restrict_members = true,
    can_manage_direct_messages = true
})
```

### Bot Commands

```lua
api.bot_command('start', 'Start the bot')
api.bot_command('help', 'Show help')

-- Scopes
api.bot_command_scope_default()
api.bot_command_scope_all_private_chats()
api.bot_command_scope_all_group_chats()
api.bot_command_scope_all_chat_administrators()
api.bot_command_scope_chat(chat_id)
api.bot_command_scope_chat_administrators(chat_id)
api.bot_command_scope_chat_member(chat_id, user_id)
```

### Menu Buttons

```lua
api.menu_button_commands()
api.menu_button_web_app(text, web_app)
api.menu_button_default()
```

### Reaction Types

```lua
api.reaction_type_emoji('👍')
api.reaction_type_custom_emoji('custom_emoji_id')
api.reaction_type_paid()
```

### Accepted Gift Types

For `set_business_account_gift_settings`:

```lua
api.accepted_gift_types({
    unlimited_gifts = true,
    limited_gifts = true,
    unique_gifts = false,
    premium_subscription = false,
    gifts_from_channels = false
})
```

### Reply Parameters

```lua
api.reply_parameters(message_id, chat_id, allow_sending_without_reply, quote, quote_parse_mode, quote_entities, quote_position)
```

### Link Preview Options

```lua
api.link_preview_options(is_disabled, url, prefer_small_media, prefer_large_media, show_above_text)
```

### Message Entity

```lua
api.message_entity(entity_type, offset, length, url, user, language, custom_emoji_id)
```

### Passport Element Errors

```lua
api.passport_element_error_data_field(error_type, field_name, data_hash, message)
api.passport_element_error_front_side(error_type, file_hash, message)
api.passport_element_error_reverse_side(error_type, file_hash, message)
api.passport_element_error_selfie(error_type, file_hash, message)
api.passport_element_error_file(error_type, file_hash, message)
api.passport_element_error_files(error_type, file_hashes, message)
api.passport_element_error_translation_file(error_type, file_hash, message)
api.passport_element_error_translation_files(error_type, file_hashes, message)
api.passport_element_error_unspecified(error_type, element_hash, message)
```
