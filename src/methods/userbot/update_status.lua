--- Set the account online status through TDLib's online option.
-- @module titogramlua.methods.userbot.update_status
-- @usage client:update_status(false) -- online
-- @usage client:update_status(true) -- offline
return function(self, offline)
    assert(offline == nil or type(offline) == 'boolean', 'offline must be a boolean')
    return self:send('setOption', {
        name = 'online', value = {['@type'] = 'optionValueBoolean', value = not offline},
    })
end
