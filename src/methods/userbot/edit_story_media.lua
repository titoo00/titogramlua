--- Replace story media through TDLib's editStory method.
-- @module titogramlua.methods.userbot.edit_story_media
-- @usage client:edit_story_media(poster_chat_id, story_id, input_story_content, opts)
return function(self, poster_chat_id, story_id, content, opts)
    return self:edit_story(poster_chat_id, story_id, content, opts)
end
