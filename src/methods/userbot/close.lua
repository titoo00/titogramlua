--- destroy this TDLib handle while preserving its encrypted database.
-- @module titogramlua.methods.userbot.close
-- @usage client:close()
return function(self)
    if self._closed then return false end
    self._running = false
    self._closed = true
    self._pending = {}
    self._streams = {}
    self._connected = false
    self.authorized = false
    self._ffi.gc(self._handle, nil)
    self._lib.td_json_client_destroy(self._handle)
    self._handle = nil
    return true
end
