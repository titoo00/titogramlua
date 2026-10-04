--- Set or clear the current user's birthday.
-- @module titogramlua.methods.userbot.update_birthday
-- @usage client:update_birthday({['@type'] = 'birthdate', day = 1, month = 1, year = 2000})
-- @usage client:update_birthday(nil) -- clear birthday
return function(self, birthdate)
    assert(birthdate == nil or (type(birthdate) == 'table' and birthdate['@type'] == 'birthdate'),
        'birthdate must be a TDLib birthdate object or nil')
    return self:send('setBirthdate', {birthdate = birthdate})
end
