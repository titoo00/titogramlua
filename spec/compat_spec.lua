local api = require('spec.test_helper')
local json = require('dkjson')

describe('legacy compatibility', function()
    before_each(function()
        api._clear_requests()
    end)

    describe('require paths', function()
        it('telegram-bot-lua.core returns api', function()
            local core = require('telegram-bot-lua.core')
            assert.is_table(core)
            assert.equals(api.version, core.version)
        end)
    end)

    describe('deprecated method names', function()
        it('get_chat_members_count forwards to get_chat_member_count', function()
            api.get_chat_members_count(123)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getChatMemberCount'))
        end)

        it('kick_chat_member forwards to ban_chat_member', function()
            api.kick_chat_member(123, 456, 1234567890)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/banChatMember'))
            assert.equals(1234567890, req.parameters.until_date)
        end)
    end)

    ---------------------------------------------------------------------------
    -- api.run() compat
    ---------------------------------------------------------------------------
    describe('api.run() positional args', function()
        -- api.run() enters an infinite loop, so we test _run_sync directly
        -- by verifying the compat wrapper calls through correctly.
        -- We override _run_sync and async.run to capture the opts.
        local captured_opts

        before_each(function()
            captured_opts = nil
        end)

        it('converts v2 positional args to opts table', function()
            local original_sync = api._run_sync
            local original_async_run = api.async.run
            api._run_sync = function(opts) captured_opts = opts end
            api.async.run = function(opts) captured_opts = opts end
            api.run(10, 30, 5, {'message'}, true)
            api._run_sync = original_sync
            api.async.run = original_async_run
            assert.is_table(captured_opts)
            assert.equals(10, captured_opts.limit)
            assert.equals(30, captured_opts.timeout)
            assert.equals(5, captured_opts.offset)
            assert.same({'message'}, captured_opts.allowed_updates)
            assert.is_true(captured_opts.use_beta_endpoint)
        end)

        it('passes v3 opts table through unchanged', function()
            local original_sync = api._run_sync
            local original_async_run = api.async.run
            api._run_sync = function(opts) captured_opts = opts end
            api.async.run = function(opts) captured_opts = opts end
            api.run({ timeout = 60, sync = true })
            api._run_sync = original_sync
            api.async.run = original_async_run
            assert.is_table(captured_opts)
            assert.equals(60, captured_opts.timeout)
            assert.is_true(captured_opts.sync)
        end)
    end)

    ---------------------------------------------------------------------------
    -- api.get_updates() compat
    ---------------------------------------------------------------------------
    describe('api.get_updates() positional args', function()
        it('converts v2 positional args to opts table', function()
            api.get_updates(30, 0, 100, {'message', 'callback_query'})
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getUpdates'))
            assert.equals(30, tonumber(req.parameters.timeout))
            assert.equals(0, tonumber(req.parameters.offset))
            assert.equals(100, tonumber(req.parameters.limit))
        end)

        it('passes v3 opts table through unchanged', function()
            api.get_updates({ timeout = 60, limit = 50 })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getUpdates'))
            assert.equals(60, tonumber(req.parameters.timeout))
            assert.equals(50, tonumber(req.parameters.limit))
        end)

        it('handles no args', function()
            api.get_updates()
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getUpdates'))
        end)
    end)

    ---------------------------------------------------------------------------
    -- api.set_webhook() compat
    ---------------------------------------------------------------------------
    describe('api.set_webhook() positional args', function()
        it('converts v2 positional args to opts table', function()
            api.set_webhook('https://example.com/hook', '/path/to/cert.pem', 40, {'message'})
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/setWebhook'))
            assert.equals('https://example.com/hook', req.parameters.url)
            assert.equals(40, tonumber(req.parameters.max_connections))
        end)

        it('passes v3 opts table through unchanged', function()
            api.set_webhook('https://example.com/hook', { max_connections = 40 })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/setWebhook'))
            assert.equals('https://example.com/hook', req.parameters.url)
            assert.equals(40, tonumber(req.parameters.max_connections))
        end)
    end)

    ---------------------------------------------------------------------------
    -- api.send_message() compat
    ---------------------------------------------------------------------------
    describe('api.send_message() positional args', function()
        it('v3 opts table works normally', function()
            api.send_message(123, 'Hello', { parse_mode = 'HTML' })
            local req = api._last_request()
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('v3 with nil opts works', function()
            api.send_message(123, 'Hello')
            local req = api._last_request()
            assert.equals('Hello', req.parameters.text)
        end)

        it('v2 shorthand: parse_mode as 3rd arg (string)', function()
            api.send_message(123, 'Hello', 'HTML')
            local req = api._last_request()
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('v2 shorthand: parse_mode as 3rd arg (boolean)', function()
            api.send_message(123, 'Hello', true)
            local req = api._last_request()
            assert.equals('MarkdownV2', req.parameters.parse_mode)
        end)

        it('v2 full positional: nil thread_id + parse_mode', function()
            api.send_message(123, 'Hello', nil, 'HTML')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendMessage'))
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('v2 full positional: numeric thread_id + parse_mode', function()
            api.send_message(123, 'Hello', 42, 'HTML')
            local req = api._last_request()
            assert.equals('HTML', req.parameters.parse_mode)
            assert.equals(42, tonumber(req.parameters.message_thread_id))
        end)

        it('v2 full positional: all args', function()
            api.send_message(123, 'Hello', nil, 'HTML', nil, nil, true, false, nil, nil)
            local req = api._last_request()
            assert.equals('HTML', req.parameters.parse_mode)
            assert.is_true(req.parameters.disable_notification)
        end)
    end)

    ---------------------------------------------------------------------------
    -- api.answer_callback_query() compat
    ---------------------------------------------------------------------------
    describe('api.answer_callback_query() positional args', function()
        it('v2 positional text works', function()
            api.answer_callback_query('123', 'Alert text', true)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/answerCallbackQuery'))
            assert.equals('Alert text', req.parameters.text)
            assert.is_true(req.parameters.show_alert)
        end)

        it('v3 opts table works', function()
            api.answer_callback_query('123', { text = 'Hello' })
            local req = api._last_request()
            assert.equals('Hello', req.parameters.text)
        end)
    end)

    ---------------------------------------------------------------------------
    -- api.edit_message_text() compat
    ---------------------------------------------------------------------------
    describe('api.edit_message_text() positional args', function()
        it('v2 positional parse_mode works', function()
            api.edit_message_text(123, 42, 'Updated', 'HTML')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/editMessageText'))
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('v3 opts table works', function()
            api.edit_message_text(123, 42, 'Updated', { parse_mode = 'HTML' })
            local req = api._last_request()
            assert.equals('HTML', req.parameters.parse_mode)
        end)
    end)

    ---------------------------------------------------------------------------
    -- Media method compat
    ---------------------------------------------------------------------------
    describe('api.send_photo() positional args', function()
        it('v3 opts table works', function()
            api.send_photo(123, 'photo.jpg', { caption = 'Nice pic', parse_mode = 'HTML' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendPhoto'))
            assert.equals('Nice pic', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('v2 positional: nil thread_id + caption + parse_mode', function()
            api.send_photo(123, 'photo.jpg', nil, 'My caption', 'HTML')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendPhoto'))
            assert.equals('My caption', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('v2 positional: numeric thread_id + caption', function()
            api.send_photo(123, 'photo.jpg', 42, 'My caption')
            local req = api._last_request()
            assert.equals(42, tonumber(req.parameters.message_thread_id))
            assert.equals('My caption', req.parameters.caption)
        end)

        it('v2 positional: has_spoiler flag', function()
            api.send_photo(123, 'photo.jpg', nil, 'Caption', nil, nil, true)
            local req = api._last_request()
            assert.equals('Caption', req.parameters.caption)
            assert.is_true(req.parameters.has_spoiler)
        end)

        it('v3 no opts works', function()
            api.send_photo(123, 'photo.jpg')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendPhoto'))
        end)
    end)

    describe('api.send_video() positional args', function()
        it('v3 opts table works', function()
            api.send_video(123, 'video.mp4', { caption = 'Cool vid', duration = 30 })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendVideo'))
            assert.equals('Cool vid', req.parameters.caption)
            assert.equals(30, tonumber(req.parameters.duration))
        end)

        it('v2 positional: duration + dimensions + caption', function()
            api.send_video(123, 'video.mp4', nil, 30, 1920, 1080, 'Cool vid', 'HTML')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendVideo'))
            assert.equals(30, tonumber(req.parameters.duration))
            assert.equals(1920, tonumber(req.parameters.width))
            assert.equals(1080, tonumber(req.parameters.height))
            assert.equals('Cool vid', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('v3 no opts works', function()
            api.send_video(123, 'video.mp4')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendVideo'))
        end)
    end)

    describe('api.send_document() positional args', function()
        it('v3 opts table works', function()
            api.send_document(123, 'file.pdf', { caption = 'Read this' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendDocument'))
            assert.equals('Read this', req.parameters.caption)
        end)

        it('v2 positional: thumbnail + caption + parse_mode', function()
            api.send_document(123, 'file.pdf', nil, nil, 'Read this', 'HTML')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendDocument'))
            assert.equals('Read this', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
        end)

        it('v3 no opts works', function()
            api.send_document(123, 'file.pdf')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendDocument'))
        end)
    end)

    describe('api.send_audio() positional args', function()
        it('v3 opts table works', function()
            api.send_audio(123, 'song.mp3', { caption = 'Great tune', duration = 180 })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendAudio'))
            assert.equals('Great tune', req.parameters.caption)
        end)

        it('v2 positional: caption + parse_mode + duration', function()
            api.send_audio(123, 'song.mp3', nil, 'Great tune', 'HTML', nil, 180, 'Artist', 'Title')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendAudio'))
            assert.equals('Great tune', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
            assert.equals(180, tonumber(req.parameters.duration))
            assert.equals('Artist', req.parameters.performer)
            assert.equals('Title', req.parameters.title)
        end)
    end)

    describe('api.send_voice() positional args', function()
        it('v2 positional: caption + parse_mode', function()
            api.send_voice(123, 'voice.ogg', nil, 'Listen', 'HTML')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendVoice'))
            assert.equals('Listen', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
        end)
    end)

    describe('api.send_animation() positional args', function()
        it('v2 positional: duration + dimensions + caption', function()
            api.send_animation(123, 'anim.gif', nil, 5, 320, 240, nil, 'Funny gif', 'HTML')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendAnimation'))
            assert.equals(5, tonumber(req.parameters.duration))
            assert.equals(320, tonumber(req.parameters.width))
            assert.equals(240, tonumber(req.parameters.height))
            assert.equals('Funny gif', req.parameters.caption)
            assert.equals('HTML', req.parameters.parse_mode)
        end)
    end)

    describe('api.send_sticker() positional args', function()
        it('v2 positional: thread_id + emoji', function()
            api.send_sticker(123, 'sticker_id', nil, '😀')
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendSticker'))
        end)

        it('v3 opts table works', function()
            api.send_sticker(123, 'sticker_id', { emoji = '😀' })
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/sendSticker'))
        end)
    end)
end)
