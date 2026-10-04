--- run the TDLib receive loop until stop() or close() is called.
-- @module titogramlua.methods.userbot.run
-- @usage client:run()
return function(self)
    assert(not self._closed, 'user client is closed')
    assert(not self._running, 'user client is already running')
    self._running = true
    while self._running and not self._closed do
        local _, err = self:receive(1)
        if err and self.on_error then self.on_error(err, self) end
    end
    return self
end
