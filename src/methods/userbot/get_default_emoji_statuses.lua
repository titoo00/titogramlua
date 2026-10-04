--- Get emoji statuses available by default.
-- @module titogramlua.methods.userbot.get_default_emoji_statuses
-- @usage client:get_default_emoji_statuses()
return function(self)
    return self:send('getDefaultEmojiStatuses')
end
