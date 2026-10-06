--- Set the account inactivity timeout using a TDLib accountTtl object.
-- @module titogramlua.methods.userbot.set_account_ttl
-- @usage client:set_account_ttl({['@type'] = 'accountTtl', days = 180})
return function(self, ttl)
    assert(type(ttl) == 'table' and ttl['@type'] == 'accountTtl', 'ttl must be a TDLib accountTtl object')
    assert(type(ttl.days) == 'number' and ttl.days >= 30 and ttl.days <= 730 and ttl.days == math.floor(ttl.days),
        'ttl.days must be an integer between 30 and 730')
    return self:send('setAccountTtl', {ttl = ttl})
end
