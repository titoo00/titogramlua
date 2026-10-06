--- Set complete TDLib privacy setting groups supplied by the caller.
-- @module titogramlua.methods.userbot.set_global_privacy_settings
-- @usage client:set_global_privacy_settings({read_date = {['@type'] = 'readDatePrivacySettings', show_read_date = false}})
-- Supported keys: archive_chat_list, read_date, new_chat, gift_settings.
-- Get existing settings first to preserve fields within a replaced group.
-- Returns a table of request IDs; results arrive through on_update.
local groups = {
    archive_chat_list = {'archiveChatListSettings', 'setArchiveChatListSettings'},
    read_date = {'readDatePrivacySettings', 'setReadDatePrivacySettings'},
    new_chat = {'newChatPrivacySettings', 'setNewChatPrivacySettings'},
    gift_settings = {'giftSettings', 'setGiftSettings'},
}
return function(self, settings)
    assert(type(settings) == 'table' and next(settings) ~= nil, 'settings must be a non-empty table')
    for key, value in pairs(settings) do
        local group = groups[key]
        assert(group, 'unknown privacy setting group: ' .. tostring(key))
        assert(type(value) == 'table' and value['@type'] == group[1],
            key .. ' must be a TDLib ' .. group[1] .. ' object')
    end
    local requests = {}
    for key, value in pairs(settings) do
        requests[key] = self:send(groups[key][2], {settings = value})
    end
    return requests
end
