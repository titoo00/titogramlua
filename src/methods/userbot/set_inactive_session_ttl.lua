--- Set how long inactive authorization sessions are kept, in days.
-- @module titogramlua.methods.userbot.set_inactive_session_ttl
-- @usage client:set_inactive_session_ttl(180)
return function(self, ttl_days)
    assert(type(ttl_days) == 'number' and ttl_days >= 1 and ttl_days <= 366 and ttl_days == math.floor(ttl_days),
        'ttl_days must be an integer between 1 and 366')
    return self:send('setInactiveSessionTtl', {inactive_session_ttl_days = ttl_days})
end
