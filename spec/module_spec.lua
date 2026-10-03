local api = require('spec.test_helper')

describe('module structure', function()
    describe('require("titogramlua")', function()
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

    describe('require("titogramlua.core") deprecated shim', function()
        it('returns the same api table as the main module', function()
            local core = require('titogramlua.core')
            assert.are.equal(api, core)
        end)

        it('is cached in package.loaded', function()
            assert.is_not_nil(package.loaded['titogramlua.core'])
        end)
    end)

    describe('rockspec module map', function()
        local rockspec_modules = {
            ['titogramlua'] = 'src/main.lua',
            ['titogramlua.config'] = 'src/config.lua',
            ['titogramlua.log'] = 'src/log.lua',
            ['titogramlua.handlers'] = 'src/handlers.lua',
            ['titogramlua.builders'] = 'src/builders.lua',
            ['titogramlua.builders_rich'] = 'src/builders_rich.lua',
            ['titogramlua.helpers'] = 'src/helpers.lua',
            ['titogramlua.session'] = 'src/session.lua',
            ['titogramlua.framework'] = 'src/framework.lua',
            ['titogramlua.tools'] = 'src/tools.lua',
            ['titogramlua.utils'] = 'src/utils.lua',
            ['titogramlua.compat'] = 'src/compat.lua',
            ['titogramlua.core'] = 'src/core.lua',
            ['titogramlua.polyfill'] = 'src/polyfill.lua',
            ['titogramlua.async'] = 'src/async.lua',
            ['titogramlua.webhook'] = 'src/webhook.lua',
            ['titogramlua.b64url'] = 'src/b64url.lua',
            ['titogramlua.methods.updates'] = 'src/methods/updates.lua',
            ['titogramlua.methods.messages'] = 'src/methods/messages.lua',
            ['titogramlua.methods.chat'] = 'src/methods/chat.lua',
            ['titogramlua.methods.members'] = 'src/methods/members.lua',
            ['titogramlua.methods.forum'] = 'src/methods/forum.lua',
            ['titogramlua.methods.stickers'] = 'src/methods/stickers.lua',
            ['titogramlua.methods.inline'] = 'src/methods/inline.lua',
            ['titogramlua.methods.payments'] = 'src/methods/payments.lua',
            ['titogramlua.methods.games'] = 'src/methods/games.lua',
            ['titogramlua.methods.passport'] = 'src/methods/passport.lua',
            ['titogramlua.methods.bot'] = 'src/methods/bot.lua',
            ['titogramlua.methods.gifts'] = 'src/methods/gifts.lua',
            ['titogramlua.methods.checklists'] = 'src/methods/checklists.lua',
            ['titogramlua.methods.stories'] = 'src/methods/stories.lua',
            ['titogramlua.methods.business'] = 'src/methods/business.lua',
            ['titogramlua.methods.suggested_posts'] = 'src/methods/suggested_posts.lua',
            ['titogramlua.methods.rich'] = 'src/methods/rich.lua',
            ['titogramlua.adapters'] = 'src/adapters/init.lua',
            ['titogramlua.adapters.db'] = 'src/adapters/db.lua',
            ['titogramlua.adapters.redis'] = 'src/adapters/redis.lua',
            ['titogramlua.adapters.llm'] = 'src/adapters/llm.lua',
            ['titogramlua.adapters.email'] = 'src/adapters/email.lua',
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
