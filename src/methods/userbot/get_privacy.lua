--- Get account privacy rules for a TDLib UserPrivacySetting.
-- @module titogramlua.methods.userbot.get_privacy
-- @usage client:get_privacy({['@type'] = 'userPrivacySettingShowStatus'})
return function(self, setting)
    assert(type(setting) == 'table' and setting['@type'], 'setting must be a TDLib UserPrivacySetting object')
    return self:send('getUserPrivacySettingRules', {setting = setting})
end
