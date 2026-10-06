--- Show a chat's stories in the main story list.
-- @module titogramlua.methods.userbot.show_chat_stories
-- @usage client:show_chat_stories(chat_id)
return function(self, chat_id)
    assert(chat_id ~= nil, 'chat_id is required')
    return self:send('setChatActiveStoriesList', {
        chat_id = chat_id,
        story_list = {['@type'] = 'storyListMain'},
    })
end
