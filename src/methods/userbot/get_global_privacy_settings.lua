--- Request archive, read-date, and new-chat privacy settings separately.
-- @module titogramlua.methods.userbot.get_global_privacy_settings
-- @usage local ids = client:get_global_privacy_settings()
-- Returns a table of request IDs; each result arrives through on_update.
return function(self)
    return {
        archive_chat_list = self:send('getArchiveChatListSettings'),
        read_date = self:send('getReadDatePrivacySettings'),
        new_chat = self:send('getNewChatPrivacySettings'),
    }
end
