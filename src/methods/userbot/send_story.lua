--- Post a photo or video story; alias of upload_story.
-- @module titogramlua.methods.userbot.send_story
-- @usage client:send_story(chat_id, input_story_content, opts)
return function(self, chat_id, content, opts)
    return self:upload_story(chat_id, content, opts)
end
