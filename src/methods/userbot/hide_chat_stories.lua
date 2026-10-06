--- Hide a chat's stories from the main story list.
-- @module titogramlua.methods.userbot.hide_chat_stories
-- @usage client:hide_chat_stories(chat_id)
return function(self, chat_id)
    assert(chat_id ~= nil, 'chat_id is required')
    return self:send('setChatActiveStoriesList', {
        story_list = {['@type'] = 'storyListArchive'},
        chat_id = chat_id,
    })
end
