--- Load active stories into TDLib's local story lists.
-- @module titogramlua.methods.userbot.get_all_stories
-- @usage client:get_all_stories(story_list)
-- @param story_list TDLib storyListMain or storyListArchive object
return function(self, story_list)
    assert(type(story_list) == 'table' and story_list['@type'],
        'story_list must be a TDLib storyListMain or storyListArchive object')
    return self:send('loadActiveStories', {story_list = story_list})
end
