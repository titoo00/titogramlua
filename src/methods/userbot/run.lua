--- run the TDLib receive loop until stop() or close() is called.
-- @module titogramlua.methods.userbot.run
-- @usage client:run()
return function(self)
    assert(not self._closed, 'user client is closed')
    assert(not self._running, 'user client is already running')
    self._running = true
    local events = require('titogramlua.methods.userbot._events')
    local ok, failure = pcall(function()
        if not self._started then
            self._started = true
            events.emit(self, 'start')
        end
        while self._running and not self._closed do
            self:receive(1)
        end
    end)
    self._running = false
    self._started = false
    local stopped, stop_failure = pcall(events.emit, self, 'stop')
    if not ok then error(failure, 0) end
    if not stopped then error(stop_failure, 0) end
    return self
end
