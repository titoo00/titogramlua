--- request that a running receive loop stop after its current receive call.
-- @module titogramlua.methods.userbot.stop
-- @usage client:stop()
return function(self)
    self._running = false
end
