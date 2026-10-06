--- Send a TDLib request and handle its matching asynchronous response.
-- @module titogramlua.methods.userbot.request
-- @usage client:request('getMe', {}, function(result, err, client) print(result and result.id) end)
-- The callback receives nil and the TDLib error object on failure.
return function(self, method, params, callback)
    assert(type(callback) == 'function', 'callback must be a function')
    local id = self:send(method, params)
    self._pending[id] = callback
    return id
end
