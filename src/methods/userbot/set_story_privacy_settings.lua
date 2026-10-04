--- Change a story's privacy rules when TDLib allows it.
-- @module titogramlua.methods.userbot.set_story_privacy_settings
-- @usage client:set_story_privacy_settings(story_id, {['@type'] = 'storyPrivacySettingsContacts', except_user_ids = {}})
return function(self, story_id, privacy_settings)
    assert(story_id ~= nil, 'story_id is required')
    assert(type(privacy_settings) == 'table' and privacy_settings['@type'],
        'privacy_settings must be a TDLib StoryPrivacySettings object')
    return self:send('setStoryPrivacySettings', {
        story_id = story_id,
        privacy_settings = privacy_settings
    })
end
