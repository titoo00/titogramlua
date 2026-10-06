--- Change the privacy rules for a story.
-- @module titogramlua.methods.userbot.edit_story_privacy
-- @usage client:edit_story_privacy(story_id, story_privacy_settings)
return function(self, story_id, privacy_settings)
    return self:set_story_privacy_settings(story_id, privacy_settings)
end
