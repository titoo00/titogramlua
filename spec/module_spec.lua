local api = require('spec.test_helper')

describe('module structure', function()
    describe('require("telegram-bot-lua")', function()
        it('returns a table', function()
            assert.is_table(api)
        end)

        it('has a version string', function()
            assert.is_string(api.version)
            assert.truthy(api.version:match('%d+%.%d+%-%d+'))
        end)

        it('has configure function', function()
            assert.is_function(api.configure)
        end)

        it('has request function', function()
            assert.is_function(api.request)
        end)

        it('has get_me function', function()
            assert.is_function(api.get_me)
        end)
    end)

    describe('require("telegram-bot-lua.core") deprecated shim', function()
        it('returns the same api table as the main module', function()
            local core = require('telegram-bot-lua.core')
            assert.are.equal(api, core)
        end)

        it('is cached in package.loaded', function()
            assert.is_not_nil(package.loaded['telegram-bot-lua.core'])
        end)
    end)

    describe('rockspec module map', function()
        local rockspec_modules = {
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
            ['telegram-bot-lua.compat'] = 'src/compat.lua',
            ['telegram-bot-lua.core'] = 'src/core.lua',
            ['telegram-bot-lua.polyfill'] = 'src/polyfill.lua',
            ['telegram-bot-lua.async'] = 'src/async.lua',
            ['telegram-bot-lua.webhook'] = 'src/webhook.lua',
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
            ['telegram-bot-lua.adapters'] = 'src/adapters/init.lua',
            ['telegram-bot-lua.adapters.db'] = 'src/adapters/db.lua',
            ['telegram-bot-lua.adapters.redis'] = 'src/adapters/redis.lua',
            ['telegram-bot-lua.adapters.llm'] = 'src/adapters/llm.lua',
            ['telegram-bot-lua.adapters.email'] = 'src/adapters/email.lua',
        }

        for mod_name, file_path in pairs(rockspec_modules) do
            it('source file exists for ' .. mod_name, function()
                local f = io.open(file_path, 'r')
                assert.is_not_nil(f, 'missing file: ' .. file_path)
                if f then f:close() end
            end)
        end

        for mod_name, _ in pairs(rockspec_modules) do
            it('can require ' .. mod_name, function()
                assert.is_not_nil(package.loaded[mod_name] or package.preload[mod_name],
                    'module not loadable: ' .. mod_name)
            end)
        end
    end)

    describe('main module entry point', function()
        it('is NOT named init.lua (avoids LuaRocks init.lua directory install)', function()
            local f = io.open('src/init.lua', 'r')
            assert.is_nil(f, 'src/init.lua should not exist; use src/main.lua so LuaRocks installs as flat file')
            if f then f:close() end
        end)

        it('main.lua exists as the entry point', function()
            local f = io.open('src/main.lua', 'r')
            assert.is_not_nil(f, 'src/main.lua must exist as the main entry point')
            if f then f:close() end
        end)
    end)

    describe('all submodules loaded into api', function()
        it('has handler methods (on_message etc)', function()
            assert.is_not_nil(api.on_message)
        end)

        it('has builder methods', function()
            assert.is_function(api.inline_result)
        end)

        it('has message methods (send_message etc)', function()
            assert.is_function(api.send_message)
        end)

        it('has chat methods', function()
            assert.is_function(api.get_chat)
        end)

        it('has member methods', function()
            assert.is_function(api.get_chat_member)
        end)

        it('has sticker methods', function()
            assert.is_function(api.send_sticker)
        end)

        it('has inline methods', function()
            assert.is_function(api.answer_inline_query)
        end)

        it('has payment methods', function()
            assert.is_function(api.send_invoice)
        end)

        it('has game methods', function()
            assert.is_function(api.send_game)
        end)

        it('has bot methods', function()
            assert.is_function(api.set_my_commands)
        end)

        it('has utility methods', function()
            assert.is_function(api.input_text_message_content)
        end)
    end)

    -- regression coverage for issue #46: ssl.https.request can raise on
    -- transient ssl/socket faults. api.request must wrap the call in pcall
    -- so the caller always gets a (false, err) return rather than a
    -- bot-killing lua error.
    describe('api.request pcall guard', function()
        local original_https_request

        before_each(function()
            local https = require('ssl.https')
            original_https_request = https.request
        end)

        after_each(function()
            local https = require('ssl.https')
            https.request = original_https_request
        end)

        it('returns (false, err) when ssl.https.request raises', function()
            local https = require('ssl.https')
            https.request = function()
                error("Copas 'try' error intermediate table: 'unexpected eof while reading'")
            end
            local ok, success, err = pcall(api._real_request, 'https://example.invalid/getMe', {})
            assert.is_true(ok, 'api.request must not propagate the raised error')
            assert.is_false(success)
            assert.truthy(tostring(err):find('unexpected eof'))
        end)

        it('returns (false, err) on the wantread case too', function()
            local https = require('ssl.https')
            https.request = function()
                error("Copas 'try' error intermediate table: 'wantread'")
            end
            local ok, success, err = pcall(api._real_request, 'https://example.invalid/getMe', {})
            assert.is_true(ok)
            assert.is_false(success)
            assert.truthy(tostring(err):find('wantread'))
        end)
    end)
end)
