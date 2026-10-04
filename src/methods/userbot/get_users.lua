--- Request one user or a list of users by their TDLib identifiers.
-- @module titogramlua.methods.userbot.get_users
-- @usage client:get_users({user_id_1, user_id_2})
return function(self, user_ids)
    if type(user_ids) == 'number' or type(user_ids) == 'string' then
        return self:send('getUser', {user_id = user_ids})
    end
    assert(type(user_ids) == 'table', 'user_ids must be a user ID or an array of user IDs')
    local requests = {}
    for i, user_id in ipairs(user_ids) do
        requests[i] = self:send('getUser', {user_id = user_id})
    end
    return requests
end
