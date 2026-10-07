--- Set a message or story reaction using TDLib parameters.
-- @module titogramlua.methods.userbot.send_reaction
-- @param params setMessageReactions fields, or setStoryReaction fields with story_id
-- @param callback optional function(result, err, client)
local support = require('titogramlua.methods.userbot._support')
local message = support.method('setMessageReactions', {chat_id='int53', message_id='int53', reaction_types='vector<ReactionType>', is_big='Bool'})
local story = support.method('setStoryReaction', {story_poster_chat_id='int53', story_id='int32', reaction_type='ReactionType', update_recent_reactions='Bool'})
return function(self, params, callback)
    assert(type(params) == 'table', 'params must be a table')
    if params.story_id ~= nil then return story(self, params, callback) end
    return message(self, params, callback)
end
