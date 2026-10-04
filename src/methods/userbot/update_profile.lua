--- Update the current user's first name, last name, and/or bio.
-- @module titogramlua.methods.userbot.update_profile
-- @usage client:update_profile({first_name = 'Ada', last_name = 'Lovelace', bio = 'Programmer'})
-- Returns a request ID for each field changed; collect results through on_update.
return function(self, fields)
    assert(type(fields) == 'table', 'fields table is required')
    local requests = {}
    if fields.first_name ~= nil or fields.last_name ~= nil then
        assert(type(fields.first_name) == 'string', 'first_name is required when changing the name')
        assert(type(fields.last_name) == 'string', 'last_name is required when changing the name')
        requests.name = self:send('setName', {
            first_name = fields.first_name, last_name = fields.last_name,
        })
    end
    if fields.bio ~= nil then
        assert(type(fields.bio) == 'string', 'bio must be a string')
        requests.bio = self:send('setBio', {bio = fields.bio})
    end
    assert(next(requests) ~= nil, 'provide first_name, last_name, or bio')
    return requests
end
