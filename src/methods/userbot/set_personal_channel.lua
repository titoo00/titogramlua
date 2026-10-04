--- Set or remove the current user's personal channel/chat.
-- @module titogramlua.methods.userbot.set_personal_channel
-- @usage client:set_personal_channel(chat_id)
-- @usage client:set_personal_channel() -- remove it
return function(self, chat_id)
    return self:send('setPersonalChat', {chat_id = chat_id or 0})
end
