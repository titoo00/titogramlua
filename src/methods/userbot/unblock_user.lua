--- Unblock a user in the signed-in account's main block list.
-- @module titogramlua.methods.userbot.unblock_user
-- @usage client:unblock_user(user_id)
return function(self, user_id)
    assert(user_id ~= nil, 'user_id is required')
    return self:send('setMessageSenderBlockList', {
        sender_id = {['@type'] = 'messageSenderUser', user_id = user_id},
        block_list = nil,
    })
end
