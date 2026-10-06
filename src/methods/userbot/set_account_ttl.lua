--- Set the account inactivity timeout using a TDLib accountTtl object.
-- @module titogramlua.methods.userbot.set_account_ttl
-- @usage client:set_account_ttl({['@type'] = 'accountTtl', days = 180})
return function(self, ttl)
    assert(type(ttl) == 'table' and ttl['@type'] == 'accountTtl', 'ttl must be a TDLib accountTtl object')
    return self:send('setAccountTtl', {ttl = ttl})
end
