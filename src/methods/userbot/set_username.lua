--- Set or remove the current user's username.
-- @module titogramlua.methods.userbot.set_username
-- @usage client:set_username('new_name')
-- @usage client:set_username('') -- remove username
return function(self, username)
    assert(username == nil or type(username) == 'string', 'username must be a string or nil')
    return self:send('setUsername', {username = username or ''})
end
