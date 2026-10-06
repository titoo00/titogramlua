--- Copy story content into a new story; TDLib requires its content and full ID.
-- @module titogramlua.methods.userbot.copy_story
-- @usage client:copy_story(chat_id, content, from_story_full_id, opts)
return function(self, chat_id, content, from_story_full_id, opts)
    return self:forward_story(chat_id, content, from_story_full_id, opts)
end
