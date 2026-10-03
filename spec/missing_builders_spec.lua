-- tests for the missing type-constructor builders
local api = require('spec.test_helper')

describe('missing builders', function()

    it('reaction_type_paid uses the paid discriminator', function()
        local t = api.reaction_type_paid()
        assert.equals('paid', t.type)
    end)

    it('keyboard_button_request_users nests request_users with coerced ids', function()
        local b = api.keyboard_button_request_users('pick users', '7', {
            user_is_bot = false,
            user_is_premium = true,
            max_quantity = '5',
            request_name = true,
            request_username = true,
            request_photo = true
        })
        assert.equals('pick users', b.text)
        assert.equals(7, b.request_users.request_id)
        assert.is_false(b.request_users.user_is_bot)
        assert.is_true(b.request_users.user_is_premium)
        assert.equals(5, b.request_users.max_quantity)
        assert.is_true(b.request_users.request_name)
        assert.is_true(b.request_users.request_username)
        assert.is_true(b.request_users.request_photo)
    end)

    it('keyboard_button_request_chat nests request_chat with chat_is_channel', function()
        local b = api.keyboard_button_request_chat('pick chat', '9', true, {
            chat_is_forum = false,
            chat_has_username = true,
            chat_is_created = true,
            user_administrator_rights = { is_anonymous = true },
            bot_administrator_rights = { can_manage_chat = true },
            bot_is_member = true,
            request_title = true,
            request_username = true,
            request_photo = true
        })
        assert.equals('pick chat', b.text)
        assert.equals(9, b.request_chat.request_id)
        assert.is_true(b.request_chat.chat_is_channel)
        assert.is_false(b.request_chat.chat_is_forum)
        assert.is_true(b.request_chat.chat_has_username)
        assert.is_true(b.request_chat.chat_is_created)
        assert.is_true(b.request_chat.user_administrator_rights.is_anonymous)
        assert.is_true(b.request_chat.bot_administrator_rights.can_manage_chat)
        assert.is_true(b.request_chat.bot_is_member)
        assert.is_true(b.request_chat.request_title)
        assert.is_true(b.request_chat.request_username)
        assert.is_true(b.request_chat.request_photo)
    end)

    it('keyboard_button_request_contact sets request_contact true', function()
        local b = api.keyboard_button_request_contact('share contact')
        assert.equals('share contact', b.text)
        assert.is_true(b.request_contact)
    end)

    it('keyboard_button_request_location sets request_location true', function()
        local b = api.keyboard_button_request_location('share location')
        assert.equals('share location', b.text)
        assert.is_true(b.request_location)
    end)

    it('keyboard_button_request_poll nests the poll type', function()
        local b = api.keyboard_button_request_poll('make a quiz', 'quiz')
        assert.equals('make a quiz', b.text)
        assert.equals('quiz', b.request_poll.type)
    end)

    it('keyboard_button_web_app nests the web app url', function()
        local b = api.keyboard_button_web_app('open app', 'https://example.com')
        assert.equals('open app', b.text)
        assert.equals('https://example.com', b.web_app.url)
    end)

    it('web_app_info carries the url', function()
        local w = api.web_app_info('https://example.com/app')
        assert.equals('https://example.com/app', w.url)
    end)

    it('login_url carries url and optional fields', function()
        local l = api.login_url('https://example.com/login', {
            forward_text = 'login here',
            bot_username = 'helper_bot',
            request_write_access = true
        })
        assert.equals('https://example.com/login', l.url)
        assert.equals('login here', l.forward_text)
        assert.equals('helper_bot', l.bot_username)
        assert.is_true(l.request_write_access)
    end)

    it('input_poll_option carries text and optional fields', function()
        local o = api.input_poll_option('option one', {
            text_parse_mode = 'HTML',
            text_entities = { { type = 'bold' } },
            media = { type = 'photo' }
        })
        assert.equals('option one', o.text)
        assert.equals('HTML', o.text_parse_mode)
        assert.equals('bold', o.text_entities[1].type)
        assert.equals('photo', o.media.type)
    end)

    it('input_paid_media_photo uses photo discriminator with inline media', function()
        local m = api.input_paid_media_photo('file_id_123')
        assert.equals('photo', m.type)
        assert.equals('file_id_123', m.media)
    end)

    it('input_paid_media_video uses video discriminator with coerced numbers', function()
        local m = api.input_paid_media_video('attach://vid', {
            thumbnail = 'attach://thumb',
            cover = 'attach://cover',
            start_timestamp = '3',
            width = '720',
            height = '1280',
            duration = '60',
            supports_streaming = true
        })
        assert.equals('video', m.type)
        assert.equals('attach://vid', m.media)
        assert.equals('attach://thumb', m.thumbnail)
        assert.equals('attach://cover', m.cover)
        assert.equals(3, m.start_timestamp)
        assert.equals(720, m.width)
        assert.equals(1280, m.height)
        assert.equals(60, m.duration)
        assert.is_true(m.supports_streaming)
    end)

    it('copy_text_button nests copy_text.text', function()
        local b = api.copy_text_button('copy', 'copied value')
        assert.equals('copy', b.text)
        assert.equals('copied value', b.copy_text.text)
    end)

    it('input_checklist holds tasks and booleans', function()
        local task = api.input_checklist_task('1', 'task one', { parse_mode = 'HTML' })
        local c = api.input_checklist('my list', { task }, {
            parse_mode = 'MarkdownV2',
            title_entities = { { type = 'italic' } },
            others_can_add_tasks = true,
            others_can_mark_tasks_as_done = false
        })
        assert.equals('my list', c.title)
        assert.equals('MarkdownV2', c.parse_mode)
        assert.equals('italic', c.title_entities[1].type)
        assert.equals(task, c.tasks[1])
        assert.is_true(c.others_can_add_tasks)
        assert.is_false(c.others_can_mark_tasks_as_done)
    end)

    it('input_checklist_task carries id, text and optional fields', function()
        local t = api.input_checklist_task('4', 'do thing', {
            parse_mode = 'HTML',
            text_entities = { { type = 'bold' } }
        })
        assert.equals(4, t.id)
        assert.equals('do thing', t.text)
        assert.equals('HTML', t.parse_mode)
        assert.equals('bold', t.text_entities[1].type)
    end)

    it('input_story_content_photo uses photo discriminator with inline photo', function()
        local s = api.input_story_content_photo('attach://story')
        assert.equals('photo', s.type)
        assert.equals('attach://story', s.photo)
    end)

    it('input_story_content_video uses video discriminator with coerced numbers', function()
        local s = api.input_story_content_video('attach://clip', {
            duration = '30',
            cover_frame_timestamp = '5',
            is_animation = true
        })
        assert.equals('video', s.type)
        assert.equals('attach://clip', s.video)
        assert.equals(30, s.duration)
        assert.equals(5, s.cover_frame_timestamp)
        assert.is_true(s.is_animation)
    end)

    it('input_profile_photo_static uses static discriminator', function()
        local p = api.input_profile_photo_static('attach://pic')
        assert.equals('static', p.type)
        assert.equals('attach://pic', p.photo)
    end)

    it('input_profile_photo_animated uses animated discriminator with coerced timestamp', function()
        local p = api.input_profile_photo_animated('attach://anim', { main_frame_timestamp = '2' })
        assert.equals('animated', p.type)
        assert.equals('attach://anim', p.animation)
        assert.equals(2, p.main_frame_timestamp)
    end)

    it('accepted_gift_types carries the gift flags', function()
        local g = api.accepted_gift_types({
            unlimited_gifts = true,
            limited_gifts = false,
            unique_gifts = true,
            premium_subscription = true,
            gifts_from_channels = false
        })
        assert.is_true(g.unlimited_gifts)
        assert.is_false(g.limited_gifts)
        assert.is_true(g.unique_gifts)
        assert.is_true(g.premium_subscription)
        assert.is_false(g.gifts_from_channels)
    end)
end)
