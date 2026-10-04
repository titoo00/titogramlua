--- send a TDLib method asynchronously.
-- @module titogramlua.methods.userbot.send
-- @usage client:send('getMe')
local json = require('dkjson')

return function(self, method, params)
    assert(not self._closed, 'user client is closed')
    assert(type(method) == 'string' and method ~= '', 'method must be a string')
    assert(type(params or {}) == 'table', 'params must be a table')
    self._next_id = self._next_id + 1
    local request = {}
    for key, value in pairs(params or {}) do request[key] = value end
    request['@type'] = method
    request['@extra'] = tostring(self._next_id)
    local payload, encode_err = json.encode(request)
    assert(payload, 'failed to encode TDLib request: ' .. tostring(encode_err))
    self._lib.td_json_client_send(self._handle, payload)
    return request['@extra']
end
