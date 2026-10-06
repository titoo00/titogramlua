--- Get account self-destruct timeout settings.
-- @module titogramlua.methods.userbot.get_account_ttl
-- @usage client:get_account_ttl()
return function(self)
    return self:send('getAccountTtl')
end
