--- run the TDLib receive loop until stop() or close() is called.
-- @module titogramlua.methods.userbot.run
-- @usage client:run()
return function(self)
    assert(not self._closed, 'user client is closed')
    assert(not self._running, 'user client is already running')
    self._running = true
    local ok, failure = pcall(function()
        while self._running and not self._closed do
            local _, err = self:receive(1)
            if err and self.on_error then self.on_error(err, self) end
        end
    end)
    self._running = false
    if not ok then error(failure, 0) end
    return self
end
