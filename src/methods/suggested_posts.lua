--- suggested_posts API methods.
-- @module telegram-bot-lua.methods.suggested_posts
return function(api)
    local config = require('telegram-bot-lua.config')

    --- approve a suggested post in a channel.
    -- @param suggested_post_id string unique identifier of the suggested post
    -- @return table|false true on success, or false on failure
    -- @return string|table the HTTP status or error details
    function api.approve_suggested_post(suggested_post_id)
        local success, res = api.request(config.endpoint .. api.token .. '/approveSuggestedPost', {
            ['suggested_post_id'] = suggested_post_id
        })
        return success, res
    end

    --- decline a suggested post in a channel.
    -- @param suggested_post_id string unique identifier of the suggested post
    -- @param opts table optional parameters (reason)
    -- @return table|false true on success, or false on failure
    -- @return string|table the HTTP status or error details
    function api.decline_suggested_post(suggested_post_id, opts)
        opts = opts or {}
        local success, res = api.request(config.endpoint .. api.token .. '/declineSuggestedPost', {
            ['suggested_post_id'] = suggested_post_id,
            ['reason'] = opts.reason
        })
        return success, res
    end
end
