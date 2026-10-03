local api = require('spec.test_helper')
local json = require('dkjson')

describe('methods', function()
    before_each(function()
        api._clear_requests()
    end)

    describe('messages', function()
        it('send_message sends to correct endpoint', function()
            api.send_message(123, 'Hello')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendMessage'))
            assert.equals(123, req.parameters.chat_id)
            assert.equals('Hello', req.parameters.text)
        end)

        it('send_message accepts message table as chat_id', function()
            api.send_message({ chat = { id = 456 }}, 'Hello')
            local req = api._last_request()
            assert.equals(456, req.parameters.chat_id)
        end)

        it('send_message passes opts', function()
            api.send_message(123, 'Hello', {
                parse_mode = 'HTML',
                disable_notification = true
            })
            local req = api._last_request()
            assert.equals('HTML', req.parameters.parse_mode)
            assert.is_true(req.parameters.disable_notification)
        end)

        it('send_message converts boolean parse_mode to MarkdownV2', function()
            api.send_message(123, 'Hello', { parse_mode = true })
            local req = api._last_request()
            assert.equals('MarkdownV2', req.parameters.parse_mode)
        end)

        it('send_message JSON-encodes reply_markup', function()
            local kb = api.inline_keyboard():row(api.row():callback_data_button('A', 'a'))
            api.send_message(123, 'Hello', { reply_markup = kb })
            local req = api._last_request()
            local decoded = json.decode(req.parameters.reply_markup)
            assert.is_table(decoded.inline_keyboard)
        end)

        it('send_message JSON-encodes link_preview_options', function()
            api.send_message(123, 'Hello', {
                link_preview_options = { is_disabled = true }
            })
            local req = api._last_request()
            local decoded = json.decode(req.parameters.link_preview_options)
            assert.is_true(decoded.is_disabled)
        end)

        it('send_message JSON-encodes reply_parameters', function()
            api.send_message(123, 'Hello', {
                reply_parameters = api.reply_parameters(42, 123, true)
            })
            local req = api._last_request()
            local decoded = json.decode(req.parameters.reply_parameters)
            assert.equals(42, decoded.message_id)
        end)

        it('send_message JSON-encodes entities', function()
            local entities = {{ type = 'bold', offset = 0, length = 5 }}
            api.send_message(123, 'Hello', { entities = entities })
            local req = api._last_request()
            local decoded = json.decode(req.parameters.entities)
            assert.equals('bold', decoded[1].type)
        end)

        it('send_message passes business_connection_id', function()
            api.send_message(123, 'Hello', { business_connection_id = 'biz_123' })
            local req = api._last_request()
            assert.equals('biz_123', req.parameters.business_connection_id)
        end)

        it('send_message passes message_effect_id', function()
            api.send_message(123, 'Hello', { message_effect_id = 'effect_1' })
            local req = api._last_request()
            assert.equals('effect_1', req.parameters.message_effect_id)
        end)

        it('send_reply validates message table', function()
            local result = api.send_reply('not a table', 'text')
            assert.is_false(result)
        end)

        it('send_reply rejects table without chat', function()
            local result = api.send_reply({ message_id = 42 }, 'text')
            assert.is_false(result)
        end)

        it('send_reply rejects table without message_id', function()
            local result = api.send_reply({ chat = { id = 123 } }, 'text')
            assert.is_false(result)
        end)

        it('send_reply creates reply_parameters', function()
            api.send_reply({ chat = { id = 123 }, message_id = 42 }, 'Hello')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendMessage'))
            local rp = json.decode(req.parameters.reply_parameters)
            assert.equals(42, rp.message_id)
        end)

        it('send_reply uses MarkdownV2 for boolean parse_mode', function()
            api.send_reply(
                { chat = { id = 123 }, message_id = 42 },
                'Hello',
                { parse_mode = true }
            )
            local req = api._last_request()
            assert.equals('MarkdownV2', req.parameters.parse_mode)
        end)

        it('send_reply preserves custom reply_parameters', function()
            local custom_rp = api.reply_parameters(99, 456, false)
            api.send_reply(
                { chat = { id = 123 }, message_id = 42 },
                'Hello',
                { reply_parameters = custom_rp }
            )
            local req = api._last_request()
            local rp = json.decode(req.parameters.reply_parameters)
            assert.equals(99, rp.message_id)
        end)

        it('forward_message works', function()
            api.forward_message(123, 456, 789)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/forwardMessage'))
            assert.equals(789, req.parameters.message_id)
        end)

        it('forward_messages encodes message_ids', function()
            api.forward_messages(123, 456, {1, 2, 3})
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/forwardMessages'))
            local ids = json.decode(req.parameters.message_ids)
            assert.equals(3, #ids)
        end)

        it('copy_message works', function()
            api.copy_message(123, 456, 789, { caption = 'New caption' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/copyMessage'))
            assert.equals('New caption', req.parameters.caption)
        end)

        it('copy_messages works', function()
            api.copy_messages(123, 456, {1, 2})
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/copyMessages'))
        end)

        -- Media methods: file and opts handling

        it('send_photo passes file param', function()
            api.send_photo(123, 'photo_file_id')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendPhoto'))
            assert.is_table(req.file)
            assert.equals('photo_file_id', req.file.photo)
        end)

        it('send_photo passes caption and opts', function()
            api.send_photo(123, 'photo_file_id', {
                caption = 'My photo',
                parse_mode = 'HTML',
                has_spoiler = true,
                show_caption_above_media = true
            })
            local req = api._last_request()
            assert.equals('My photo', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
            assert.is_true(req.parameters.has_spoiler)
            assert.is_true(req.parameters.show_caption_above_media)
        end)

        it('send_audio passes file and thumbnail', function()
            api.send_audio(123, 'audio_file_id', { thumbnail = 'thumb_id' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendAudio'))
            assert.equals('audio_file_id', req.file.audio)
            assert.equals('thumb_id', req.file.thumbnail)
        end)

        it('send_audio passes caption and metadata', function()
            api.send_audio(123, 'audio_file_id', {
                caption = 'My audio',
                duration = 120,
                performer = 'Artist',
                title = 'Song'
            })
            local req = api._last_request()
            assert.equals('My audio', req.parameters.caption)
            assert.equals(120, req.parameters.duration)
            assert.equals('Artist', req.parameters.performer)
            assert.equals('Song', req.parameters.title)
        end)

        it('send_document passes file and thumbnail', function()
            api.send_document(123, 'doc_file_id', { thumbnail = 'thumb_id' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendDocument'))
            assert.equals('doc_file_id', req.file.document)
            assert.equals('thumb_id', req.file.thumbnail)
        end)

        it('send_document passes caption', function()
            api.send_document(123, 'doc_file_id', { caption = 'My doc' })
            local req = api._last_request()
            assert.equals('My doc', req.parameters.caption)
        end)

        it('send_video passes file and thumbnail', function()
            api.send_video(123, 'video_file_id', { thumbnail = 'thumb_id' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendVideo'))
            assert.equals('video_file_id', req.file.video)
            assert.equals('thumb_id', req.file.thumbnail)
        end)

        it('send_video passes caption and all opts', function()
            api.send_video(123, 'video_file_id', {
                caption = 'My video',
                parse_mode = 'HTML',
                duration = 60,
                width = 1920,
                height = 1080,
                has_spoiler = true,
                supports_streaming = true,
                show_caption_above_media = true
            })
            local req = api._last_request()
            assert.equals('My video', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
            assert.equals(60, req.parameters.duration)
            assert.equals(1920, req.parameters.width)
            assert.equals(1080, req.parameters.height)
            assert.is_true(req.parameters.has_spoiler)
            assert.is_true(req.parameters.supports_streaming)
            assert.is_true(req.parameters.show_caption_above_media)
        end)

        it('send_video JSON-encodes caption_entities', function()
            local entities = {{ type = 'bold', offset = 0, length = 5 }}
            api.send_video(123, 'video_file_id', { caption_entities = entities })
            local req = api._last_request()
            local decoded = json.decode(req.parameters.caption_entities)
            assert.equals('bold', decoded[1].type)
        end)

        it('send_animation passes file and thumbnail', function()
            api.send_animation(123, 'anim_file_id', { thumbnail = 'thumb_id' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendAnimation'))
            assert.equals('anim_file_id', req.file.animation)
            assert.equals('thumb_id', req.file.thumbnail)
        end)

        it('send_animation passes caption', function()
            api.send_animation(123, 'anim_file_id', { caption = 'My GIF' })
            local req = api._last_request()
            assert.equals('My GIF', req.parameters.caption)
        end)

        it('send_voice passes file param', function()
            api.send_voice(123, 'voice_file_id')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendVoice'))
            assert.equals('voice_file_id', req.file.voice)
        end)

        it('send_voice passes caption', function()
            api.send_voice(123, 'voice_file_id', { caption = 'My voice' })
            local req = api._last_request()
            assert.equals('My voice', req.parameters.caption)
        end)

        it('send_video_note passes file and thumbnail', function()
            api.send_video_note(123, 'vnote_file_id', { thumbnail = 'thumb_id' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendVideoNote'))
            assert.equals('vnote_file_id', req.file.video_note)
            assert.equals('thumb_id', req.file.thumbnail)
        end)

        it('send_video_note passes duration and length', function()
            api.send_video_note(123, 'vnote_file_id', { duration = 30, length = 240 })
            local req = api._last_request()
            assert.equals(30, req.parameters.duration)
            assert.equals(240, req.parameters.length)
        end)

        it('send_media_group encodes media', function()
            local media = {
                { type = 'photo', media = 'photo1' },
                { type = 'photo', media = 'photo2' }
            }
            api.send_media_group(123, media)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendMediaGroup'))
            local decoded = json.decode(req.parameters.media)
            assert.equals(2, #decoded)
        end)

        -- Poll tests

        it('send_poll encodes options', function()
            api.send_poll(123, 'Question?', {
                { text = 'Yes' }, { text = 'No' }
            })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendPoll'))
            local opts = json.decode(req.parameters.options)
            assert.equals(2, #opts)
        end)

        it('send_poll passes question_parse_mode', function()
            api.send_poll(123, '*Bold question*', {
                { text = 'Yes' }, { text = 'No' }
            }, { question_parse_mode = 'MarkdownV2' })
            local req = api._last_request()
            assert.equals('MarkdownV2', req.parameters.question_parse_mode)
        end)

        it('send_poll JSON-encodes question_entities', function()
            local entities = {{ type = 'bold', offset = 0, length = 4 }}
            api.send_poll(123, 'Question?', {
                { text = 'Yes' }, { text = 'No' }
            }, { question_entities = entities })
            local req = api._last_request()
            local decoded = json.decode(req.parameters.question_entities)
            assert.equals('bold', decoded[1].type)
        end)

        it('send_poll passes quiz options', function()
            api.send_poll(123, 'Capital of France?', {
                { text = 'Berlin' }, { text = 'Paris' }, { text = 'London' }
            }, {
                poll_type = 'quiz',
                correct_option_id = 1,
                explanation = 'Paris is the capital',
                explanation_parse_mode = 'HTML'
            })
            local req = api._last_request()
            assert.equals('quiz', req.parameters.type)
            assert.equals(1, req.parameters.correct_option_id)
            assert.equals('Paris is the capital', req.parameters.explanation)
        end)

        it('send_poll JSON-encodes explanation_entities', function()
            local entities = {{ type = 'italic', offset = 0, length = 5 }}
            api.send_poll(123, 'Q?', {
                { text = 'A' }, { text = 'B' }
            }, { explanation_entities = entities })
            local req = api._last_request()
            local decoded = json.decode(req.parameters.explanation_entities)
            assert.equals('italic', decoded[1].type)
        end)

        it('send_poll passes v9.6 parameters', function()
            api.send_poll(123, 'Q?', {
                { text = 'A' }, { text = 'B' }
            }, {
                correct_option_ids = {0, 1},
                allows_revoting = true,
                shuffle_options = true,
                allow_adding_options = true,
                hide_results_until_closes = true,
                description = 'Poll description',
                description_parse_mode = 'HTML'
            })
            local req = api._last_request()
            local decoded_ids = json.decode(req.parameters.correct_option_ids)
            assert.equals(0, decoded_ids[1])
            assert.equals(1, decoded_ids[2])
            assert.is_true(req.parameters.allows_revoting)
            assert.is_true(req.parameters.shuffle_options)
            assert.is_true(req.parameters.allow_adding_options)
            assert.is_true(req.parameters.hide_results_until_closes)
            assert.equals('Poll description', req.parameters.description)
            assert.equals('HTML', req.parameters.description_parse_mode)
        end)

        it('send_poll JSON-encodes description_entities', function()
            local entities = {{ type = 'bold', offset = 0, length = 4 }}
            api.send_poll(123, 'Q?', {
                { text = 'A' }, { text = 'B' }
            }, { description_entities = entities })
            local req = api._last_request()
            local decoded = json.decode(req.parameters.description_entities)
            assert.equals('bold', decoded[1].type)
        end)

        it('send_poll backward compat correct_option_id still works', function()
            api.send_poll(123, 'Q?', {
                { text = 'A' }, { text = 'B' }
            }, { correct_option_id = 0 })
            local req = api._last_request()
            assert.equals(0, req.parameters.correct_option_id)
        end)

        -- other send methods

        it('send_dice works', function()
            api.send_dice(123, { emoji = '🎲' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendDice'))
        end)

        it('send_chat_action works', function()
            api.send_chat_action(123, 'typing')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendChatAction'))
            assert.equals('typing', req.parameters.action)
        end)

        it('send_location passes coordinates', function()
            api.send_location(123, 51.5074, -0.1278)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendLocation'))
            assert.equals(51.5074, req.parameters.latitude)
            assert.equals(-0.1278, req.parameters.longitude)
        end)

        it('send_location passes live period and opts', function()
            api.send_location(123, 51.5074, -0.1278, {
                live_period = 3600,
                heading = 90,
                proximity_alert_radius = 100
            })
            local req = api._last_request()
            assert.equals(3600, req.parameters.live_period)
            assert.equals(90, req.parameters.heading)
            assert.equals(100, req.parameters.proximity_alert_radius)
        end)

        it('send_venue passes all fields', function()
            api.send_venue(123, 51.5074, -0.1278, 'Big Ben', 'Westminster, London', {
                foursquare_id = 'fsq_123',
                google_place_id = 'gp_123'
            })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendVenue'))
            assert.equals('Big Ben', req.parameters.title)
            assert.equals('Westminster, London', req.parameters.address)
            assert.equals('fsq_123', req.parameters.foursquare_id)
        end)

        it('send_contact passes phone and name', function()
            api.send_contact(123, '+447911123456', 'John', {
                last_name = 'Doe',
                vcard = 'BEGIN:VCARD'
            })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendContact'))
            assert.equals('+447911123456', req.parameters.phone_number)
            assert.equals('John', req.parameters.first_name)
            assert.equals('Doe', req.parameters.last_name)
        end)

        it('set_message_reaction works', function()
            api.set_message_reaction(123, 42, {
                reaction = {{ type = 'emoji', emoji = '👍' }}
            })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/setMessageReaction'))
            local decoded = json.decode(req.parameters.reaction)
            assert.equals('👍', decoded[1].emoji)
        end)

        it('send_paid_media works', function()
            api.send_paid_media(123, 100, {})
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendPaidMedia'))
            assert.equals(100, req.parameters.star_count)
        end)

        -- Edit methods

        it('edit_message_text works', function()
            api.edit_message_text(123, 42, 'Updated', { parse_mode = 'HTML' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/editMessageText'))
            assert.equals('Updated', req.parameters.text)
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('edit_message_text converts boolean parse_mode', function()
            api.edit_message_text(123, 42, 'Updated', { parse_mode = true })
            local req = api._last_request()
            assert.equals('MarkdownV2', req.parameters.parse_mode)
        end)

        it('edit_message_text passes inline_message_id', function()
            api.edit_message_text(nil, nil, 'Updated', { inline_message_id = 'inline_123' })
            local req = api._last_request()
            assert.equals('inline_123', req.parameters.inline_message_id)
        end)

        it('edit_message_caption works', function()
            api.edit_message_caption(123, 42, {
                caption = 'New caption',
                parse_mode = true
            })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/editMessageCaption'))
            assert.equals('New caption', req.parameters.caption)
            assert.equals('MarkdownV2', req.parameters.parse_mode)
        end)

        it('edit_message_media works', function()
            local media = { type = 'photo', media = 'photo_id' }
            api.edit_message_media(123, 42, media)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/editMessageMedia'))
            local decoded = json.decode(req.parameters.media)
            assert.equals('photo', decoded.type)
        end)

        it('edit_message_reply_markup works', function()
            local kb = api.inline_keyboard():row(api.row():callback_data_button('OK', 'ok'))
            api.edit_message_reply_markup(123, 42, { reply_markup = kb })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/editMessageReplyMarkup'))
            local decoded = json.decode(req.parameters.reply_markup)
            assert.is_table(decoded.inline_keyboard)
        end)

        it('edit_message_live_location works', function()
            api.edit_message_live_location(123, 42, 52.0, 13.0, { heading = 180 })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/editMessageLiveLocation'))
            assert.equals(52.0, req.parameters.latitude)
            assert.equals(180, req.parameters.heading)
        end)

        it('stop_message_live_location works', function()
            api.stop_message_live_location(123, 42)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/stopMessageLiveLocation'))
        end)

        it('stop_poll works', function()
            api.stop_poll(123, 42)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/stopPoll'))
        end)

        it('delete_message works', function()
            api.delete_message(123, 42)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/deleteMessage'))
        end)

        it('delete_messages encodes message_ids', function()
            api.delete_messages(123, {1, 2, 3})
            local req = api._last_request()
            local ids = json.decode(req.parameters.message_ids)
            assert.equals(3, #ids)
        end)
    end)

    describe('chat', function()
        it('get_chat works', function()
            api.get_chat(123)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getChat'))
        end)

        it('get_chat_member_count uses correct endpoint (bug fix)', function()
            api.get_chat_member_count(123)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getChatMemberCount'))
            assert.falsy(req.endpoint:find('/getChatMembersCount'))
        end)

        it('set_chat_title truncates to 128 chars', function()
            api.set_chat_title(123, string.rep('a', 200))
            local req = api._last_request()
            assert.equals(128, #req.parameters.title)
        end)

        it('pin_chat_message works', function()
            api.pin_chat_message(123, 42, { disable_notification = true })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/pinChatMessage'))
        end)
    end)

    describe('members', function()
        it('ban_chat_member uses correct endpoint (bug fix)', function()
            api.ban_chat_member(123, 456)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/banChatMember'))
            assert.falsy(req.endpoint:find('/kickChatMember'))
        end)

        it('promote_chat_member includes can_manage_direct_messages', function()
            api.promote_chat_member(123, 456, { can_manage_direct_messages = true })
            local req = api._last_request()
            assert.is_true(req.parameters.can_manage_direct_messages)
        end)

        it('promote_chat_member includes can_manage_tags', function()
            api.promote_chat_member(123, 456, { can_manage_tags = true })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/promoteChatMember'))
            assert.is_true(req.parameters.can_manage_tags)
        end)

        it('set_chat_member_tag works', function()
            api.set_chat_member_tag(123, 456, { tag = 'VIP' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/setChatMemberTag'))
            assert.equals(123, req.parameters.chat_id)
            assert.equals(456, req.parameters.user_id)
            assert.equals('VIP', req.parameters.tag)
        end)

        it('set_chat_member_tag clears tag when no tag provided', function()
            api.set_chat_member_tag(123, 456)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/setChatMemberTag'))
            assert.is_nil(req.parameters.tag)
        end)

        it('get_user_profile_audios works', function()
            api.get_user_profile_audios(456, { offset = 0, limit = 10 })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getUserProfileAudios'))
            assert.equals(456, req.parameters.user_id)
            assert.equals(0, req.parameters.offset)
            assert.equals(10, req.parameters.limit)
        end)
    end)

    describe('stickers', function()
        it('send_sticker passes file param', function()
            api.send_sticker(123, 'sticker_file_id')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendSticker'))
            assert.equals('sticker_file_id', req.file.sticker)
        end)

        it('send_sticker passes opts', function()
            api.send_sticker(123, 'sticker_file_id', { emoji = '😀' })
            local req = api._last_request()
            assert.equals('😀', req.parameters.emoji)
        end)

        it('upload_sticker_file works', function()
            api.upload_sticker_file(456, 'sticker_data', 'static')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/uploadStickerFile'))
            assert.equals(456, req.parameters.user_id)
            assert.equals('static', req.parameters.sticker_format)
        end)

        it('set_sticker_set_thumbnail passes file', function()
            api.set_sticker_set_thumbnail('my_set', 456, { thumbnail = 'thumb_data' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/setStickerSetThumbnail'))
            assert.equals('thumb_data', req.file.thumbnail)
        end)
    end)

    describe('inline', function()
        it('answer_callback_query works', function()
            api.answer_callback_query('123', { text = 'Hello!', show_alert = true })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/answerCallbackQuery'))
            assert.equals('Hello!', req.parameters.text)
        end)

        it('answer_inline_query encodes results', function()
            local result = api.inline_result():type('article'):id('1'):title('Test')
                :input_message_content(api.input_text_message_content('Hello'))
            api.answer_inline_query('123', result)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/answerInlineQuery'))
        end)
    end)

    describe('bot', function()
        it('get_file works', function()
            api.get_file('file_id_123')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getFile'))
        end)

        it('set_my_commands works', function()
            api.set_my_commands({
                api.bot_command('start', 'Start'),
                api.bot_command('help', 'Help')
            })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/setMyCommands'))
        end)

        it('get_managed_bot_token works', function()
            api.get_managed_bot_token(789)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getManagedBotToken'))
            assert.equals(789, req.parameters.user_id)
        end)

        it('replace_managed_bot_token works', function()
            api.replace_managed_bot_token(789)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/replaceManagedBotToken'))
            assert.equals(789, req.parameters.user_id)
        end)

        it('save_prepared_keyboard_button works', function()
            api.save_prepared_keyboard_button(789, { type = 'test' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/savePreparedKeyboardButton'))
            assert.equals(789, req.parameters.user_id)
        end)
    end)

    describe('updates', function()
        it('get_updates works', function()
            api.get_updates({ timeout = 30 })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getUpdates'))
            assert.equals(30, req.parameters.timeout)
        end)

        it('set_webhook works', function()
            api.set_webhook('https://example.com/webhook', { max_connections = 40 })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/setWebhook'))
            assert.equals('https://example.com/webhook', req.parameters.url)
        end)
    end)

    describe('payments', function()
        it('send_invoice works', function()
            local prices = api.prices():labeled_price('Item', 100)
            api.send_invoice(123, 'Title', 'Desc', 'payload', 'USD', prices)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendInvoice'))
        end)

        it('refund_star_payment works', function()
            api.refund_star_payment(123, 'charge_id')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/refundStarPayment'))
        end)
    end)
end)
