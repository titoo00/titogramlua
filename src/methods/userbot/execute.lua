--- execute a synchronous TDLib method.
-- @module titogramlua.methods.userbot.execute
-- @usage local version = client:execute('getOption', {name = 'version'})
local json = require('dkjson')

return function(self, method, params)
    assert(not self._closed, 'user client is closed')
    assert(type(method) == 'string' and method ~= '', 'method must be a string')
    local request = {}
    for key, value in pairs(params or {}) do request[key] = value end
    request['@type'] = method
    local payload, encode_err = json.encode(request)
    assert(payload, 'failed to encode TDLib request: ' .. tostring(encode_err))
    local result = self._lib.td_json_client_execute(self._handle, payload)
    if result == nil then return nil end
    return json.decode(self._ffi.string(result))
end
