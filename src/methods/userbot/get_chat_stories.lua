--- Get a chat's currently active stories.
-- @module titogramlua.methods.userbot.get_chat_stories
-- @usage client:get_chat_stories(chat_id)
return function(self, chat_id)
    return self:get_chat_active_stories(chat_id)
end
