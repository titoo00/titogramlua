--- receive and dispatch one TDLib update or response.
-- @module titogramlua.methods.userbot.receive
-- @usage local update, err = client:receive(1)
local json = require('dkjson')
local mime = require('mime')
local events = require('titogramlua.methods.userbot._events')

local function dispatch(self, update)
    local kind = update['@type']
    local id = update['@extra']
    local callback = id ~= nil and self._pending and self._pending[tostring(id)]
    if callback then
        self._pending[tostring(id)] = nil
        if kind == 'error' then callback(nil, update, self)
        else callback(update, nil, self) end
    end
    if kind == 'updateAuthorizationState' then
        local state = update.authorization_state or {}
        local state_type = state['@type']
        self.authorized = state_type == 'authorizationStateReady'
        if state_type == 'authorizationStateWaitTdlibParameters' then
            self:send('setTdlibParameters', self._tdlib_parameters)
        elseif state_type == 'authorizationStateWaitEncryptionKey' then
            self:send('checkDatabaseEncryptionKey', {
                encryption_key = mime.b64(self._encryption_key)
            })
        elseif state_type == 'authorizationStateReady' then
            self.authorized = true
            events.emit(self, 'authorized', state)
        elseif state_type == 'authorizationStateClosed' then
            self._running = false
        end
        events.emit(self, 'auth_state', state)
    end
    events.dispatch(self, update)
end

return function(self, timeout)
    assert(not self._closed, 'user client is closed')
    local result = self._lib.td_json_client_receive(self._handle, tonumber(timeout) or 1)
    if result == nil then return nil end
    local update, _, decode_err = json.decode(self._ffi.string(result))
    if type(update) ~= 'table' then
        local err = decode_err or 'TDLib update must be an object'
        events.emit(self, 'error', err)
        return nil, err
    end
    dispatch(self, update)
    if update['@type'] == 'error' then
        events.emit(self, 'error', update)
        return update, update
    end
    return update
end
