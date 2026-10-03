-- End-to-end integration tests using the real Telegram Bot API
-- Requires a .env file with BOT_TOKEN set
-- Run with: busted --run e2e

-- Load .env file
local function load_env()
    local f = io.open('.env', 'r')
    if not f then return nil end
    local env = {}
    for line in f:lines() do
        local key, value = line:match('^([%w_]+)%s*=%s*(.+)$')
        if key and value then
            env[key] = value
        end
    end
    f:close()
    return env
end

local env = load_env()
if not env or not env.BOT_TOKEN then
    print('Skipping e2e tests: no .env file or BOT_TOKEN not set')
    return
end

_G._TEST = true
package.path = './src/?.lua;./src/?/init.lua;' .. package.path

local module_map = {
    ['telegram-bot-lua'] = 'src/main.lua',
    ['telegram-bot-lua.config'] = 'src/config.lua',
    ['telegram-bot-lua.log'] = 'src/log.lua',
    ['telegram-bot-lua.handlers'] = 'src/handlers.lua',
    ['telegram-bot-lua.builders'] = 'src/builders.lua',
    ['telegram-bot-lua.builders_rich'] = 'src/builders_rich.lua',
    ['telegram-bot-lua.helpers'] = 'src/helpers.lua',
    ['telegram-bot-lua.session'] = 'src/session.lua',
    ['telegram-bot-lua.framework'] = 'src/framework.lua',
    ['telegram-bot-lua.tools'] = 'src/tools.lua',
    ['telegram-bot-lua.utils'] = 'src/utils.lua',
    ['telegram-bot-lua.async'] = 'src/async.lua',
    ['telegram-bot-lua.webhook'] = 'src/webhook.lua',
    ['telegram-bot-lua.compat'] = 'src/compat.lua',
    ['telegram-bot-lua.core'] = 'src/core.lua',
    ['telegram-bot-lua.polyfill'] = 'src/polyfill.lua',
    ['telegram-bot-lua.b64url'] = 'src/b64url.lua',
    ['telegram-bot-lua.methods.updates'] = 'src/methods/updates.lua',
    ['telegram-bot-lua.methods.messages'] = 'src/methods/messages.lua',
    ['telegram-bot-lua.methods.chat'] = 'src/methods/chat.lua',
    ['telegram-bot-lua.methods.members'] = 'src/methods/members.lua',
    ['telegram-bot-lua.methods.forum'] = 'src/methods/forum.lua',
    ['telegram-bot-lua.methods.stickers'] = 'src/methods/stickers.lua',
    ['telegram-bot-lua.methods.inline'] = 'src/methods/inline.lua',
    ['telegram-bot-lua.methods.payments'] = 'src/methods/payments.lua',
    ['telegram-bot-lua.methods.games'] = 'src/methods/games.lua',
    ['telegram-bot-lua.methods.passport'] = 'src/methods/passport.lua',
    ['telegram-bot-lua.methods.bot'] = 'src/methods/bot.lua',
    ['telegram-bot-lua.methods.gifts'] = 'src/methods/gifts.lua',
    ['telegram-bot-lua.methods.checklists'] = 'src/methods/checklists.lua',
    ['telegram-bot-lua.methods.stories'] = 'src/methods/stories.lua',
    ['telegram-bot-lua.methods.business'] = 'src/methods/business.lua',
    ['telegram-bot-lua.methods.suggested_posts'] = 'src/methods/suggested_posts.lua',
    ['telegram-bot-lua.methods.rich'] = 'src/methods/rich.lua',
    ['telegram-bot-lua.middleware'] = 'src/middleware.lua',
    ['telegram-bot-lua.mcp'] = 'src/mcp.lua',
    ['telegram-bot-lua.adapters'] = 'src/adapters/init.lua',
    ['telegram-bot-lua.adapters.db'] = 'src/adapters/db.lua',
    ['telegram-bot-lua.adapters.redis'] = 'src/adapters/redis.lua',
    ['telegram-bot-lua.adapters.llm'] = 'src/adapters/llm.lua',
    ['telegram-bot-lua.adapters.email'] = 'src/adapters/email.lua',
}
for mod_name, file_path in pairs(module_map) do
    if not package.preload[mod_name] then
        package.preload[mod_name] = function()
            return dofile(file_path)
        end
    end
end

local api = require('telegram-bot-lua')
api.token = env.BOT_TOKEN

-- Get bot info for use in tests
local bot_info = api.get_me()
local bot_id = bot_info and bot_info.result and bot_info.result.id

describe('e2e', function()

    -- =========================================================================
    -- Bot identity
    -- =========================================================================
    describe('bot identity', function()
        it('get_me returns bot info', function()
            local result = api.get_me()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.is_true(result.result.is_bot)
            assert.is_string(result.result.first_name)
            assert.is_number(result.result.id)
            assert.is_string(result.result.username)
        end)
    end)

    -- =========================================================================
    -- Bot commands (default scope)
    -- =========================================================================
    describe('bot commands (default scope)', function()
        it('set_my_commands succeeds', function()
            local commands = {
                api.bot_command('start', 'Start the bot'),
                api.bot_command('help', 'Show help')
            }
            local result = api.set_my_commands(commands)
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_commands returns the commands', function()
            local result = api.get_my_commands()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.equals(2, #result.result)
            assert.equals('start', result.result[1].command)
            assert.equals('help', result.result[2].command)
        end)

        it('delete_my_commands succeeds', function()
            local result = api.delete_my_commands()
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_commands returns empty after delete', function()
            local result = api.get_my_commands()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals(0, #result.result)
        end)
    end)

    -- =========================================================================
    -- Bot commands (with scope and language_code)
    -- =========================================================================
    describe('bot commands (scoped)', function()
        it('set_my_commands with all_private_chats scope', function()
            local commands = {
                api.bot_command('settings', 'Bot settings'),
            }
            local result = api.set_my_commands(commands, {
                scope = { type = 'all_private_chats' }
            })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_commands with all_private_chats scope', function()
            local result = api.get_my_commands({
                scope = { type = 'all_private_chats' }
            })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.equals(1, #result.result)
            assert.equals('settings', result.result[1].command)
        end)

        it('set_my_commands with language_code', function()
            local commands = {
                api.bot_command('inicio', 'Iniciar el bot'),
            }
            local result = api.set_my_commands(commands, {
                language_code = 'es'
            })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_commands with language_code', function()
            local result = api.get_my_commands({ language_code = 'es' })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.equals(1, #result.result)
            assert.equals('inicio', result.result[1].command)
        end)

        it('cleanup: delete scoped commands', function()
            local r1 = api.delete_my_commands({ scope = { type = 'all_private_chats' } })
            assert.is_true(r1.ok)
            local r2 = api.delete_my_commands({ language_code = 'es' })
            assert.is_true(r2.ok)
        end)
    end)

    -- =========================================================================
    -- Bot name
    -- =========================================================================
    describe('bot name', function()
        local original_name

        it('get_my_name returns name', function()
            local result = api.get_my_name()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            original_name = result.result.name or ''
        end)

        it('set_my_name succeeds', function()
            local result = api.set_my_name('E2E Test Bot Name')
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_name confirms change', function()
            local result = api.get_my_name()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals('E2E Test Bot Name', result.result.name)
        end)

        it('set_my_name with language_code', function()
            local result = api.set_my_name('Bot de prueba', { language_code = 'es' })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_name with language_code', function()
            local result = api.get_my_name({ language_code = 'es' })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals('Bot de prueba', result.result.name)
        end)

        it('cleanup: reset name for es', function()
            local result = api.set_my_name('', { language_code = 'es' })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('restores original name', function()
            local result = api.set_my_name(original_name)
            assert.is_table(result)
            assert.is_true(result.ok)
        end)
    end)

    -- =========================================================================
    -- Bot description
    -- =========================================================================
    describe('bot description', function()
        local original_description

        it('get_my_description returns description', function()
            local result = api.get_my_description()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            original_description = result.result.description or ''
        end)

        it('set_my_description succeeds', function()
            local result = api.set_my_description('E2E test bot description')
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_description confirms change', function()
            local result = api.get_my_description()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals('E2E test bot description', result.result.description)
        end)

        it('restores original description', function()
            local result = api.set_my_description(original_description)
            assert.is_table(result)
            assert.is_true(result.ok)
        end)
    end)

    -- =========================================================================
    -- Bot short description
    -- =========================================================================
    describe('bot short description', function()
        local original_short_description

        it('get_my_short_description returns short description', function()
            local result = api.get_my_short_description()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            original_short_description = result.result.short_description or ''
        end)

        it('set_my_short_description succeeds', function()
            local result = api.set_my_short_description('E2E short desc')
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_short_description confirms change', function()
            local result = api.get_my_short_description()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals('E2E short desc', result.result.short_description)
        end)

        it('restores original short description', function()
            local result = api.set_my_short_description(original_short_description)
            assert.is_table(result)
            assert.is_true(result.ok)
        end)
    end)

    -- =========================================================================
    -- Default administrator rights
    -- =========================================================================
    describe('default administrator rights', function()
        local original_rights

        it('get_my_default_administrator_rights returns rights', function()
            local result = api.get_my_default_administrator_rights()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            original_rights = result.result
        end)

        it('set_my_default_administrator_rights succeeds', function()
            local result = api.set_my_default_administrator_rights({
                rights = {
                    can_manage_chat = true,
                    can_delete_messages = true,
                    can_manage_video_chats = false,
                    can_restrict_members = false,
                    can_promote_members = false,
                    can_change_info = true,
                    can_invite_users = true,
                    can_post_stories = false,
                    can_edit_stories = false,
                    can_delete_stories = false,
                    can_pin_messages = true,
                    can_manage_topics = false,
                    is_anonymous = false
                }
            })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_my_default_administrator_rights confirms change', function()
            local result = api.get_my_default_administrator_rights()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_true(result.result.can_manage_chat)
            assert.is_true(result.result.can_delete_messages)
            assert.is_true(result.result.can_change_info)
            assert.is_true(result.result.can_invite_users)
            assert.is_true(result.result.can_pin_messages)
        end)

        it('get_my_default_administrator_rights for channels', function()
            local result = api.get_my_default_administrator_rights({ for_channels = true })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)

        it('restores original rights', function()
            local result = api.set_my_default_administrator_rights({
                rights = original_rights
            })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)
    end)

    -- =========================================================================
    -- Chat menu button
    -- =========================================================================
    describe('chat menu button', function()
        it('get_chat_menu_button returns default', function()
            local result = api.get_chat_menu_button()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.is_string(result.result.type)
        end)

        it('set_chat_menu_button to commands type', function()
            local result = api.set_chat_menu_button({
                menu_button = { type = 'commands' }
            })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_chat_menu_button confirms commands type', function()
            local result = api.get_chat_menu_button()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals('commands', result.result.type)
        end)

        it('set_chat_menu_button to default type', function()
            local result = api.set_chat_menu_button({
                menu_button = { type = 'default' }
            })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)
    end)

    -- =========================================================================
    -- Webhook management
    -- =========================================================================
    describe('webhook management', function()
        it('delete_webhook succeeds', function()
            local result = api.delete_webhook()
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_webhook_info shows no webhook', function()
            local result = api.get_webhook_info()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.equals('', result.result.url)
        end)

        it('set_webhook succeeds', function()
            local result = api.set_webhook('https://example.com/e2e-test-webhook')
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_webhook_info confirms webhook', function()
            local result = api.get_webhook_info()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.equals('https://example.com/e2e-test-webhook', result.result.url)
        end)

        it('cleans up webhook', function()
            local result = api.delete_webhook({ drop_pending_updates = true })
            assert.is_table(result)
            assert.is_true(result.ok)
        end)

        it('get_webhook_info confirms cleanup', function()
            local result = api.get_webhook_info()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.equals('', result.result.url)
        end)
    end)

    -- =========================================================================
    -- Updates
    -- =========================================================================
    describe('get_updates', function()
        it('returns updates array', function()
            local result = api.get_updates({ timeout = 0, limit = 1 })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)

        it('returns updates with allowed_updates filter', function()
            local result = api.get_updates({
                timeout = 0,
                limit = 1,
                allowed_updates = { 'message' }
            })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)
    end)

    -- =========================================================================
    -- Star transactions
    -- =========================================================================
    describe('star transactions', function()
        it('get_star_transactions returns transactions', function()
            local result = api.get_star_transactions()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)

        it('get_star_transactions with opts', function()
            local result = api.get_star_transactions({ offset = 0, limit = 10 })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)
    end)

    -- =========================================================================
    -- Forum topic icon stickers
    -- =========================================================================
    describe('forum topic icon stickers', function()
        it('get_forum_topic_icon_stickers returns sticker list', function()
            local result = api.get_forum_topic_icon_stickers()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            -- Should return a non-empty list of stickers
            assert.is_true(#result.result > 0)
            -- Each sticker should have basic fields
            local sticker = result.result[1]
            assert.is_string(sticker.file_id)
            assert.is_string(sticker.file_unique_id)
            assert.is_string(sticker.type)
        end)
    end)

    -- =========================================================================
    -- User profile photos (using bot's own ID)
    -- =========================================================================
    describe('user profile photos', function()
        it('get_user_profile_photos returns photos', function()
            if not bot_id then pending('no bot_id') end
            local result = api.get_user_profile_photos(bot_id)
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.is_number(result.result.total_count)
            assert.is_table(result.result.photos)
        end)

        it('get_user_profile_photos with offset and limit', function()
            if not bot_id then pending('no bot_id') end
            local result = api.get_user_profile_photos(bot_id, { offset = 0, limit = 1 })
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
            assert.is_number(result.result.total_count)
        end)
    end)

    -- =========================================================================
    -- Available gifts
    -- =========================================================================
    describe('available gifts', function()
        it('get_available_gifts returns gift list', function()
            local result = api.get_available_gifts()
            assert.is_table(result)
            assert.is_true(result.ok)
            assert.is_table(result.result)
        end)
    end)

    -- =========================================================================
    -- Sticker sets (using known public sets)
    -- =========================================================================
    describe('sticker sets', function()
        it('get_sticker_set returns set info for known set', function()
            local result = api.get_sticker_set('AnimatedEmojies')
            if result and result.ok then
                assert.is_table(result.result)
                assert.equals('AnimatedEmojies', result.result.name)
                assert.is_string(result.result.title)
                assert.is_table(result.result.stickers)
                assert.is_true(#result.result.stickers > 0)
            else
                -- Set may not exist, that's fine - verify error structure
                assert.is_false(result)
            end
        end)

        it('get_sticker_set returns error for invalid name', function()
            local result, err = api.get_sticker_set('totally_nonexistent_sticker_set_12345')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)
    end)

    -- =========================================================================
    -- Create invoice link (Telegram Stars / XTR currency)
    -- =========================================================================
    describe('create invoice link', function()
        it('create_invoice_link returns a URL', function()
            local prices = {{ label = 'Test Item', amount = 1 }}
            local result = api.create_invoice_link(
                'E2E Test Invoice',
                'Test description for e2e',
                'e2e_test_payload_' .. os.time(),
                'XTR',
                prices
            )
            if result and result.ok then
                assert.is_string(result.result)
                -- Telegram invoice links start with https://
                assert.truthy(result.result:match('^https://'))
            else
                -- If bot doesn't have payments enabled, verify error structure
                assert.is_false(result)
            end
        end)
    end)

    -- =========================================================================
    -- Error handling
    -- =========================================================================
    describe('error handling', function()
        it('send_message returns error for invalid chat_id', function()
            local result, err = api.send_message(0, 'test')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('get_file returns error for invalid file_id', function()
            local result, err = api.get_file('invalid_file_id_that_does_not_exist')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('get_chat returns error for invalid chat_id', function()
            local result, err = api.get_chat(0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('get_chat_member returns error for invalid params', function()
            local result, err = api.get_chat_member(0, 0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_photo returns error for invalid chat_id', function()
            local result, err = api.send_photo(0, 'invalid_photo')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_video returns error for invalid chat_id', function()
            local result, err = api.send_video(0, 'invalid_video')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_audio returns error for invalid chat_id', function()
            local result, err = api.send_audio(0, 'invalid_audio')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_document returns error for invalid chat_id', function()
            local result, err = api.send_document(0, 'invalid_doc')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_animation returns error for invalid chat_id', function()
            local result, err = api.send_animation(0, 'invalid_anim')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_voice returns error for invalid chat_id', function()
            local result, err = api.send_voice(0, 'invalid_voice')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_video_note returns error for invalid chat_id', function()
            local result, err = api.send_video_note(0, 'invalid_videonote')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_sticker returns error for invalid chat_id', function()
            local result, err = api.send_sticker(0, 'invalid_sticker')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_location returns error for invalid chat_id', function()
            local result, err = api.send_location(0, 51.5074, -0.1278)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_venue returns error for invalid chat_id', function()
            local result, err = api.send_venue(0, 51.5074, -0.1278, 'Test Venue', '123 Test St')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_contact returns error for invalid chat_id', function()
            local result, err = api.send_contact(0, '+1234567890', 'Test')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_poll returns error for invalid chat_id', function()
            local options = {
                { text = 'Option A' },
                { text = 'Option B' }
            }
            local result, err = api.send_poll(0, 'Test question?', options)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_dice returns error for invalid chat_id', function()
            local result, err = api.send_dice(0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_chat_action returns error for invalid chat_id', function()
            local result, err = api.send_chat_action(0, 'typing')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('forward_message returns error for invalid params', function()
            local result, err = api.forward_message(0, 0, 0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('copy_message returns error for invalid params', function()
            local result, err = api.copy_message(0, 0, 0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('edit_message_text returns error for invalid params', function()
            local result, err = api.edit_message_text(0, 0, 'test')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('delete_message returns error for invalid params', function()
            local result, err = api.delete_message(0, 0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('ban_chat_member returns error for invalid params', function()
            local result, err = api.ban_chat_member(0, 0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('pin_chat_message returns error for invalid params', function()
            local result, err = api.pin_chat_message(0, 0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('create_forum_topic returns error for invalid chat', function()
            local result, err = api.create_forum_topic(0, 'Test Topic')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_invoice returns error for invalid chat_id', function()
            local prices = {{ label = 'Item', amount = 100 }}
            local result, err = api.send_invoice(0, 'Title', 'Desc', 'payload', 'XTR', prices)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('get_user_gifts returns error for invalid user', function()
            local result, err = api.get_user_gifts(0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('answer_inline_query returns error for invalid query_id', function()
            local result, err = api.answer_inline_query('invalid_id', {})
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('answer_callback_query returns error for invalid query_id', function()
            local result, err = api.answer_callback_query('invalid_id')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('leave_chat returns error for invalid chat_id', function()
            local result, err = api.leave_chat(0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('export_chat_invite_link returns error for invalid chat', function()
            local result, err = api.export_chat_invite_link(0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('get_chat_member_count returns error for invalid chat', function()
            local result, err = api.get_chat_member_count(0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('set_chat_title returns error for invalid chat', function()
            local result, err = api.set_chat_title(0, 'Test')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('set_chat_description returns error for invalid chat', function()
            local result, err = api.set_chat_description(0, 'Test')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('get_chat_administrators returns error for invalid chat', function()
            local result, err = api.get_chat_administrators(0)
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('set_chat_permissions returns error for invalid chat', function()
            local result, err = api.set_chat_permissions(0, { can_send_messages = true })
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('send_game returns error for invalid chat_id', function()
            local result, err = api.send_game(0, 'testgame')
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)

        it('set_passport_data_errors returns error for invalid user', function()
            local result, err = api.set_passport_data_errors(0, {})
            assert.is_false(result)
            assert.is_table(err)
            assert.is_number(err.error_code)
        end)
    end)

    -- =========================================================================
    -- Custom emoji stickers
    -- =========================================================================
    describe('custom emoji stickers', function()
        it('get_custom_emoji_stickers returns error for invalid IDs', function()
            local result, err = api.get_custom_emoji_stickers({'invalid_emoji_id'})
            -- Should either succeed with empty array or fail gracefully
            if result then
                assert.is_table(result)
                assert.is_true(result.ok)
            else
                assert.is_false(result)
                assert.is_table(err)
            end
        end)
    end)

    -- =========================================================================
    -- Helpers (no-network, validate logic only)
    -- =========================================================================
    describe('helpers', function()
        it('send_reply returns false for invalid message', function()
            local result = api.send_reply(nil, 'test')
            assert.is_false(result)
        end)

        it('send_reply returns false for message missing chat', function()
            local result = api.send_reply({ message_id = 1 }, 'test')
            assert.is_false(result)
        end)

        it('send_reply returns false for message missing message_id', function()
            local result = api.send_reply({ chat = { id = 1 } }, 'test')
            assert.is_false(result)
        end)
    end)

    -- =========================================================================
    -- Builder utilities (no-network, validate constructors)
    -- =========================================================================
    describe('builders', function()
        it('bot_command builds correct structure', function()
            local cmd = api.bot_command('test', 'Test command')
            assert.is_table(cmd)
            assert.equals('test', cmd.command)
            assert.equals('Test command', cmd.description)
        end)

        it('keyboard builder works', function()
            local kb = api.keyboard(true, false, false)
            assert.is_table(kb)
            assert.is_table(kb.keyboard)
            assert.is_true(kb.resize_keyboard)
        end)

        it('inline_keyboard builder works', function()
            local ikb = api.inline_keyboard()
            assert.is_table(ikb)
            assert.is_table(ikb.inline_keyboard)
        end)

        it('row builder supports chaining', function()
            local r = api.row()
            assert.is_table(r)
            local chained = r:callback_data_button('btn', 'data')
            assert.equals(r, chained)
            assert.equals(1, #r)
            assert.equals('btn', r[1].text)
            assert.equals('data', r[1].callback_data)
        end)
    end)
end)
