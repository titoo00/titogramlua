--- Search messages using TDLib searchMessages parameters.
-- @module titogramlua.methods.userbot.search_messages
-- @usage client:search_messages({query = 'invoice', offset = '', limit = 20})
return function(self, params)
    assert(type(params) == 'table', 'params table is required')
    assert(type(params.query) == 'string', 'params.query must be a string')
    local request = {}
    for key, value in pairs(params) do request[key] = value end
    return self:send('searchMessages', request)
end
