-- Test helper: sets up package paths and mocks for testing without network
_G._TEST = true

-- Set up package paths to find our modules
package.path = './src/?.lua;./src/?/init.lua;' .. package.path

-- Pre-register our module names to match rockspec mappings
local module_map = {
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
    ['titogramlua.async'] = 'src/async.lua',
    ['titogramlua.webhook'] = 'src/webhook.lua',
    ['titogramlua.compat'] = 'src/compat.lua',
    ['titogramlua.core'] = 'src/core.lua',
    ['titogramlua.polyfill'] = 'src/polyfill.lua',
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
    ['titogramlua.middleware'] = 'src/middleware.lua',
    ['titogramlua.mcp'] = 'src/mcp.lua',
    ['titogramlua.adapters'] = 'src/adapters/init.lua',
    ['titogramlua.adapters.db'] = 'src/adapters/db.lua',
    ['titogramlua.adapters.redis'] = 'src/adapters/redis.lua',
    ['titogramlua.adapters.llm'] = 'src/adapters/llm.lua',
    ['titogramlua.adapters.email'] = 'src/adapters/email.lua',
}

for mod_name, file_path in pairs(module_map) do
    if not package.preload[mod_name] then
        package.preload[mod_name] = function()
            return dofile(file_path)
        end
    end
end

-- Mock api.request so we don't need a real token/network
local api = require('titogramlua')
api.token = 'test:TOKEN'
api.info = { id = 123456, first_name = 'TestBot', username = 'test_bot', is_bot = true }
api.info.name = api.info.first_name

-- store request calls for assertions. guard against re-running test_helper
-- after the mock has already been installed: busted may load the helper via
-- the .busted config AND via `require('spec.test_helper')` in spec files,
-- and a naive second pass would re-capture the mock itself as
-- api._real_request, defeating any test that calls the real implementation.
api._requests = api._requests or {}
if not api._real_request then
    api._real_request = api._http_request
end
api.request = function(endpoint, parameters, file)
    table.insert(api._requests, {
        endpoint = endpoint,
        parameters = parameters,
        file = file
    })
    -- return a mock success response
    return { ok = true, result = true }, 200
end

-- Helper to get last request
function api._last_request()
    return api._requests[#api._requests]
end

-- Helper to clear request history
function api._clear_requests()
    api._requests = {}
end

-- Helper to mock a specific response for the next request
function api._mock_response(response)
    local original = api.request
    api.request = function(endpoint, parameters, file)
        api.request = original
        table.insert(api._requests, {
            endpoint = endpoint,
            parameters = parameters,
            file = file
        })
        return response, 200
    end
end

return api
