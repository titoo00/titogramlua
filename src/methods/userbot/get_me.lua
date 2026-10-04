--- Get the currently authenticated user.
-- @module titogramlua.methods.userbot.get_me
-- @usage client:get_me()
return function(self)
    return self:send('getMe')
end
