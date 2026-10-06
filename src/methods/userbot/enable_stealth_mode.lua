--- Enable Telegram Stories stealth mode for the current account.
-- @module titogramlua.methods.userbot.enable_stealth_mode
-- @usage client:enable_stealth_mode()
return function(self)
    return self:send('activateStoryStealthMode')
end
