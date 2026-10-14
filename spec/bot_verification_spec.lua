require('spec.test_helper')

-- Nested userbot modules are composed at runtime and are not listed in the
-- rockspec module map used by the test helper.
package.preload['titogramlua.methods.userbot._support'] = function()
    return dofile('src/methods/userbot/_support.lua')
end
package.preload['titogramlua.methods.userbot._events'] = function()
    return dofile('src/methods/userbot/_events.lua')
end
package.preload['titogramlua.methods.userbot._operations'] = function()
    return dofile('src/methods/userbot/_operations.lua')
end

local operations = require('titogramlua.methods.userbot._operations')

describe('userbot bot verification reader', function()
    local verification = {
        ['@type'] = 'botVerification',
        bot_user_id = 7,
        icon_custom_emoji_id = '123',
        custom_description = {
            ['@type'] = 'formattedText',
            text = 'Verified by Acme',
            entities = {
                {['@type'] = 'textEntity', offset = 12, length = 4,
                    type = {['@type'] = 'textEntityTypeBold'}}
            }
        }
    }

    local function mock_client(info, expected_method)
        local calls = {}
        local client = {
            request = function(self, method, params, callback)
                calls[#calls + 1] = {method = method, params = params}
                assert.equals(expected_method, method)
                callback(info, nil, self)
                return 'request-1'
            end
        }
        return client, calls
    end

    it('reads and normalizes a user verification while preserving description entities', function()
        local client, calls = mock_client({bot_verification = verification}, 'getUserFullInfo')
        local result, failure
        client.get_bot_verification = operations.get_bot_verification

        local request_id = client:get_bot_verification({user_id = 42}, function(value, err)
            result, failure = value, err
        end)

        assert.equals('request-1', request_id)
        assert.is_nil(failure)
        assert.equals(42, calls[1].params.user_id)
        assert.equals('botVerification', result['@type'])
        assert.equals(7, result.bot_user_id)
        assert.equals(7, result.bot.id)
        assert.equals('123', result.custom_emoji_id)
        assert.equals('123', result.icon_custom_emoji_id)
        assert.equals('Verified by Acme', result.description)
        assert.equals(1, #result.description_entities)
        assert.equals(12, result.description_entities[1].offset)
        assert.same(verification.custom_description, result.custom_description)
    end)

    it('reads verification for a supergroup or channel', function()
        local client, calls = mock_client({bot_verification = verification}, 'getSupergroupFullInfo')
        local result
        client.get_bot_verification = operations.get_bot_verification

        client:get_bot_verification({supergroup_id = 9001}, function(value)
            result = value
        end)

        assert.equals(9001, calls[1].params.supergroup_id)
        assert.equals(7, result.bot.id)
    end)

    it('returns nil when Telegram has no verification details', function()
        local client = mock_client({}, 'getUserFullInfo')
        local result = 'not-set'
        client.get_bot_verification = operations.get_bot_verification

        client:get_bot_verification({user_id = 42}, function(value)
            result = value
        end)

        assert.is_nil(result)
    end)

    it('requires exactly one supported target', function()
        local client = {request = function() error('request should not be sent') end}
        client.get_bot_verification = operations.get_bot_verification

        assert.has_error(function()
            client:get_bot_verification({})
        end)
        assert.has_error(function()
            client:get_bot_verification({user_id = 42, supergroup_id = 9001})
        end)
    end)
end)
