--- Set the global account privacy rules.
-- @module titogramlua.methods.userbot.set_global_privacy_settings
-- @usage client:set_global_privacy_settings(setting, rules)
return function(self, settings)
    assert(type(settings) == 'table' and settings['@type'] == 'globalPrivacySettings',
        'settings must be a TDLib globalPrivacySettings object')
    return self:send('setGlobalPrivacySettings', {settings = settings})
end
