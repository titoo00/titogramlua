--- Set account privacy rules for a TDLib UserPrivacySetting.
-- @module titogramlua.methods.userbot.set_privacy
-- @usage client:set_privacy(setting, {['@type'] = 'userPrivacySettingRules', rules = rules})
return function(self, setting, rules)
    assert(type(setting) == 'table' and setting['@type'], 'setting must be a TDLib UserPrivacySetting object')
    assert(type(rules) == 'table' and rules['@type'], 'rules must be a TDLib UserPrivacySettingRules object')
    return self:send('setUserPrivacySettingRules', {setting = setting, rules = rules})
end
