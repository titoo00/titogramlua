--- Get the global account privacy settings.
-- @module titogramlua.methods.userbot.get_global_privacy_settings
-- @usage client:get_global_privacy_settings()
return function(self)
    return self:send('getGlobalPrivacySettings')
end
