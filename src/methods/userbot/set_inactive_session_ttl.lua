--- Set how long inactive authorization sessions are kept, in days.
-- @module titogramlua.methods.userbot.set_inactive_session_ttl
-- @usage client:set_inactive_session_ttl(180)
return function(self, ttl_days)
    assert(type(ttl_days) == 'number' and ttl_days >= 0, 'ttl_days must be a non-negative number')
    return self:send('setInactiveSessionTtl', {inactive_session_ttl_days = math.floor(ttl_days)})
end
