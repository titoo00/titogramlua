--- receive and dispatch one TDLib update or response.
-- @module titogramlua.methods.userbot.receive
-- @usage local update, err = client:receive(1)
local json = require('dkjson')
local mime = require('mime')

local function dispatch(self, update)
    local kind = update['@type']
    if kind == 'updateAuthorizationState' then
        local state = update.authorization_state or {}
        local state_type = state['@type']
        if state_type == 'authorizationStateWaitTdlibParameters' then
            self:send('setTdlibParameters', self._tdlib_parameters)
        elseif state_type == 'authorizationStateWaitEncryptionKey' then
            self:send('checkDatabaseEncryptionKey', {
                encryption_key = mime.b64(self._encryption_key)
            })
        elseif state_type == 'authorizationStateReady' then
            self.authorized = true
            if self.on_authorized then self.on_authorized(state, self) end
        elseif state_type == 'authorizationStateClosed' then
            self.authorized = false
        end
        if self.on_auth_state then self.on_auth_state(state, self) end
    elseif kind == 'updateNewMessage' and self.on_message then
        self.on_message(update.message, update, self)
    end
    if self.on_update then self.on_update(update, self) end
end

return function(self, timeout)
    assert(not self._closed, 'user client is closed')
    local result = self._lib.td_json_client_receive(self._handle, tonumber(timeout) or 1)
    if result == nil then return nil end
    local update, _, decode_err = json.decode(self._ffi.string(result))
    if not update then return nil, decode_err end
    dispatch(self, update)
    return update
end
