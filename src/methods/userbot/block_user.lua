--- Block a user from contacting the signed-in account.
-- @module titogramlua.methods.userbot.block_user
-- @usage client:block_user(user_id)
return function(self, user_id)
    assert(user_id ~= nil, 'user_id is required')
    return self:send('setMessageSenderBlockList', {
        sender_id = {['@type'] = 'messageSenderUser', user_id = user_id},
        block_list = {['@type'] = 'blockListMain'},
    })
end
