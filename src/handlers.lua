--- update handler stubs and dispatch logic.
-- @module telegram-bot-lua.handlers
return function(api)

    --- @section update handler stubs
    -- override these functions to handle specific update types.
    -- each receives the relevant update object as its only argument.

    --- called for every update received, before type-specific routing.
    -- @param update table the raw update object
    function api.on_update(_) end
    --- called for any new message (after chat-type-specific handlers).
    -- @param message table the message object
    function api.on_message(_) end
    --- called for new messages in private chats.
    -- @param message table the message object
    function api.on_private_message(_) end
    --- called for new messages in group chats.
    -- @param message table the message object
    function api.on_group_message(_) end
    --- called for new messages in supergroup chats.
    -- @param message table the message object
    function api.on_supergroup_message(_) end
    --- called when a callback query is received from an inline keyboard button.
    -- @param callback_query table the callback query object
    function api.on_callback_query(_) end
    --- called when an inline query is received.
    -- @param inline_query table the inline query object
    function api.on_inline_query(_) end
    --- called for new posts in channels.
    -- @param channel_post table the channel post message object
    function api.on_channel_post(_) end
    --- called when a message is edited.
    -- @param edited_message table the edited message object
    function api.on_edited_message(_) end
    --- called when a message is edited in a private chat.
    -- @param edited_message table the edited message object
    function api.on_edited_private_message(_) end
    --- called when a message is edited in a group chat.
    -- @param edited_message table the edited message object
    function api.on_edited_group_message(_) end
    --- called when a message is edited in a supergroup chat.
    -- @param edited_message table the edited message object
    function api.on_edited_supergroup_message(_) end
    --- called when a channel post is edited.
    -- @param edited_channel_post table the edited channel post object
    function api.on_edited_channel_post(_) end
    --- called when a chosen inline result is received.
    -- @param chosen_inline_result table the chosen inline result object
    function api.on_chosen_inline_result(_) end
    --- called when a shipping query is received (payments).
    -- @param shipping_query table the shipping query object
    function api.on_shipping_query(_) end
    --- called when a pre-checkout query is received (payments).
    -- @param pre_checkout_query table the pre-checkout query object
    function api.on_pre_checkout_query(_) end
    --- called when a poll state changes.
    -- @param poll table the poll object with current state
    function api.on_poll(_) end
    --- called when a user changes their vote in a non-anonymous poll.
    -- @param poll_answer table the poll answer object
    function api.on_poll_answer(_) end
    --- called when a message reaction is changed by a user.
    -- @param message_reaction table the message reaction updated object
    function api.on_message_reaction(_) end
    --- called when anonymous reactions on a message are changed.
    -- @param message_reaction_count table the reaction count updated object
    function api.on_message_reaction_count(_) end
    --- called when the bot's own chat member status is updated.
    -- @param my_chat_member table the chat member updated object
    function api.on_my_chat_member(_) end
    --- called when a chat member's status is updated.
    -- @param chat_member table the chat member updated object
    function api.on_chat_member(_) end
    --- called when a user sends a join request to a chat.
    -- @param chat_join_request table the chat join request object
    function api.on_chat_join_request(_) end
    --- called when a chat boost is added.
    -- @param chat_boost table the chat boost updated object
    function api.on_chat_boost(_) end
    --- called when a chat boost is removed.
    -- @param removed_chat_boost table the chat boost removed object
    function api.on_removed_chat_boost(_) end
    --- called when a business connection is updated.
    -- @param business_connection table the business connection object
    function api.on_business_connection(_) end
    --- called for new messages from a connected business account.
    -- @param business_message table the business message object
    function api.on_business_message(_) end
    --- called when a business message is edited.
    -- @param edited_business_message table the edited business message object
    function api.on_edited_business_message(_) end
    --- called when business messages are deleted.
    -- @param deleted_business_messages table the deleted messages object
    function api.on_deleted_business_messages(_) end
    --- called when paid media is purchased.
    -- @param purchased_paid_media table the purchased paid media object
    function api.on_purchased_paid_media(_) end
    --- called when a managed bot update is received.
    -- @param managed_bot table the managed bot updated object
    function api.on_managed_bot(_) end
    --- called when the bot receives a guest message (Bot API 10.0).
    -- @param guest_message table the guest message update object
    function api.on_guest_message(_) end

    --- raw dispatch: routes an update directly to the appropriate handler.
    -- called by the middleware chain as the final step, or directly when
    -- no middleware is registered.
    -- @param update table the update object to dispatch
    -- @return any the return value of the matched handler
    function api._dispatch_update(update)
        api.on_update(update)
        -- framework layer (commands, hears, conversations) runs first; if it
        -- fully handles the update the legacy on_* handlers are skipped.
        if api._framework_handle and api._framework_handle(update) then
            return true
        end
        if update.message then
            if update.message.chat.type == 'private' then
                api.on_private_message(update.message)
            elseif update.message.chat.type == 'group' then
                api.on_group_message(update.message)
            elseif update.message.chat.type == 'supergroup' then
                api.on_supergroup_message(update.message)
            end
            return api.on_message(update.message)
        elseif update.edited_message then
            if update.edited_message.chat.type == 'private' then
                api.on_edited_private_message(update.edited_message)
            elseif update.edited_message.chat.type == 'group' then
                api.on_edited_group_message(update.edited_message)
            elseif update.edited_message.chat.type == 'supergroup' then
                api.on_edited_supergroup_message(update.edited_message)
            end
            return api.on_edited_message(update.edited_message)
        elseif update.callback_query then
            return api.on_callback_query(update.callback_query)
        elseif update.inline_query then
            return api.on_inline_query(update.inline_query)
        elseif update.channel_post then
            return api.on_channel_post(update.channel_post)
        elseif update.edited_channel_post then
            return api.on_edited_channel_post(update.edited_channel_post)
        elseif update.chosen_inline_result then
            return api.on_chosen_inline_result(update.chosen_inline_result)
        elseif update.shipping_query then
            return api.on_shipping_query(update.shipping_query)
        elseif update.pre_checkout_query then
            return api.on_pre_checkout_query(update.pre_checkout_query)
        elseif update.poll then
            return api.on_poll(update.poll)
        elseif update.poll_answer then
            return api.on_poll_answer(update.poll_answer)
        elseif update.message_reaction then
            return api.on_message_reaction(update.message_reaction)
        elseif update.message_reaction_count then
            return api.on_message_reaction_count(update.message_reaction_count)
        elseif update.my_chat_member then
            return api.on_my_chat_member(update.my_chat_member)
        elseif update.chat_member then
            return api.on_chat_member(update.chat_member)
        elseif update.chat_join_request then
            return api.on_chat_join_request(update.chat_join_request)
        elseif update.chat_boost then
            return api.on_chat_boost(update.chat_boost)
        elseif update.removed_chat_boost then
            return api.on_removed_chat_boost(update.removed_chat_boost)
        elseif update.business_connection then
            return api.on_business_connection(update.business_connection)
        elseif update.business_message then
            return api.on_business_message(update.business_message)
        elseif update.edited_business_message then
            return api.on_edited_business_message(update.edited_business_message)
        elseif update.deleted_business_messages then
            return api.on_deleted_business_messages(update.deleted_business_messages)
        elseif update.purchased_paid_media then
            return api.on_purchased_paid_media(update.purchased_paid_media)
        elseif update.managed_bot then
            return api.on_managed_bot(update.managed_bot)
        elseif update.guest_message then
            return api.on_guest_message(update.guest_message)
        end
        return false
    end

    --- process an update through the middleware chain (if any) then dispatch.
    -- @param update table the update object to process
    -- @return any the return value of the matched handler, or false
    function api.process_update(update)
        if not update then
            return false
        end
        if #api._middleware > 0 or (api._scoped_middleware and next(api._scoped_middleware)) then
            return api._run_middleware(update)
        end
        return api._dispatch_update(update)
    end

    --- start the bot's polling loop.
    -- by default uses copas for concurrent update processing.
    -- pass { sync = true } for single-threaded sequential processing.
    -- @param opts table optional parameters
    -- @param opts.sync boolean use synchronous polling instead of async
    -- @param opts.limit number max number of updates per poll (default 1)
    -- @param opts.timeout number long-polling timeout in seconds (default 0)
    -- @param opts.offset number identifier of the first update to be returned
    -- @param opts.allowed_updates table list of update types to receive
    function api.run(opts)
        opts = opts or {}
        if opts.sync then
            return api._run_sync(opts)
        end
        -- default: async via copas
        return api.async.run(opts)
    end

    --- request that the synchronous polling loop exit at its next iteration.
    function api.stop_sync()
        api._sync_running = false
    end

    --- single-threaded synchronous polling loop (opt-in via sync = true).
    -- @param opts table same options as api.run
    function api._run_sync(opts)
        opts = opts or {}
        local limit = tonumber(opts.limit) or 1
        local timeout = tonumber(opts.timeout) or 0
        local offset = tonumber(opts.offset) or 0
        local allowed_updates = opts.allowed_updates
        local use_beta_endpoint = opts.use_beta_endpoint
        api._sync_running = true
        -- backoff state for transient polling failures: start at 1s, double
        -- on each consecutive failure up to 30s, reset on the next success.
        local backoff = 1
        local max_backoff = 30
        -- sleeper is injectable so tests can fast-forward backoff without
        -- the loop actually sleeping. defaults to a real wall-clock sleep
        -- using socket.select (avoids spawning a shell, unlike os.execute).
        local sleeper = opts._sleeper or function(seconds)
            local ok, socket = pcall(require, 'socket')
            if ok and socket and socket.sleep then
                socket.sleep(seconds)
            else
                os.execute('sleep ' .. tostring(math.max(1, math.floor(seconds))))
            end
        end
        while api._sync_running do
            local pok, updates, perr = pcall(api.get_updates, {
                timeout = timeout,
                offset = offset,
                limit = limit,
                allowed_updates = allowed_updates,
                use_beta_endpoint = use_beta_endpoint
            })
            if not pok then
                if api.debug then
                    print('Polling error [' .. tostring(updates) .. '], backing off ' .. backoff .. 's')
                end
                sleeper(backoff)
                backoff = math.min(backoff * 2, max_backoff)
            elseif updates and type(updates) == 'table' and updates.result then
                backoff = 1
                for _, v in ipairs(updates.result) do
                    -- protect the loop: a throwing handler must not kill the bot.
                    local ok, err = pcall(api.process_update, v)
                    if not ok and api.debug then
                        print('Update handler error: ' .. tostring(err))
                    end
                    offset = v.update_id + 1
                    if api.metrics then api.metrics.incr('updates') end
                end
            else
                -- get_updates returned false or a malformed payload. back off
                -- so a sustained server-side error doesn't pin a cpu. a 409 is a
                -- configuration error (duplicate poller / webhook still set),
                -- not transient, so surface it loudly.
                if type(perr) == 'table' and tonumber(perr.error_code) == 409 then
                    api.log.warn('polling conflict (409): another getUpdates is running for this ' ..
                        'bot, or a webhook is still set. stop the other instance or call ' ..
                        'api.delete_webhook().')
                elseif api.debug then
                    print('Polling returned no result, backing off ' .. backoff .. 's')
                end
                sleeper(backoff)
                backoff = math.min(backoff * 2, max_backoff)
            end
        end
    end
end
