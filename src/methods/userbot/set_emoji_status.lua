--- Set or clear an emoji status on the account or a chat.
-- @module titogramlua.methods.userbot.set_emoji_status
-- @usage client:set_emoji_status(nil, {['@type'] = 'emojiStatus', type = {['@type'] = 'emojiStatusTypeCustomEmoji', custom_emoji_id = '123'}})
-- @usage client:set_emoji_status(chat_id, nil) -- clear chat status
return function(self, chat_id, emoji_status)
    if chat_id == nil then
        return self:send('setEmojiStatus', {emoji_status = emoji_status})
    end
    return self:send('setChatEmojiStatus', {chat_id = chat_id, emoji_status = emoji_status})
end
