--- legacy compatibility layer for v2 to v3 migration.
-- @module titogramlua.compat
-- Legacy compatibility layer for v2 -> v3 migration
-- Provides deprecated method names, positional-arg wrappers, and
-- require('titogramlua.core') support so v2 code runs on v3.
return function(api)
    local warned = {}
    local function deprecation_warning(old_name, new_name)
        if not warned[old_name] then
            io.stderr:write(string.format(
                '[titogramlua] DEPRECATED: %s is deprecated, use %s instead\n',
                old_name, new_name
            ))
            warned[old_name] = true
        end
    end

    ---------------------------------------------------------------------------
    -- Renamed methods
    ---------------------------------------------------------------------------

    function api.get_chat_members_count(chat_id)
        deprecation_warning('get_chat_members_count', 'get_chat_member_count')
        return api.get_chat_member_count(chat_id)
    end

    function api.kick_chat_member(chat_id, user_id, until_date)
        deprecation_warning('kick_chat_member', 'ban_chat_member')
        return api.ban_chat_member(chat_id, user_id, { until_date = until_date })
    end

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    local v3_run = api.run
    function api.run(opts_or_limit, ...)
        if type(opts_or_limit) == 'number' then
            deprecation_warning('run(limit, timeout, ...)', 'run(opts)')
            local args = {...}
            return v3_run({
                limit = opts_or_limit,
                timeout = args[1],
                offset = args[2],
                allowed_updates = args[3],
                use_beta_endpoint = args[4]
            })
        end
        return v3_run(opts_or_limit)
    end

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    local v3_get_updates = api.get_updates
    function api.get_updates(opts_or_timeout, ...)
        if type(opts_or_timeout) == 'number' then
            deprecation_warning('get_updates(timeout, offset, ...)', 'get_updates(opts)')
            local args = {...}
            return v3_get_updates({
                timeout = opts_or_timeout,
                offset = args[1],
                limit = args[2],
                allowed_updates = args[3],
                use_beta_endpoint = args[4]
            })
        end
        return v3_get_updates(opts_or_timeout)
    end

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    local v3_set_webhook = api.set_webhook
    function api.set_webhook(url, opts_or_cert, ...)
        if opts_or_cert ~= nil and type(opts_or_cert) ~= 'table' then
            deprecation_warning('set_webhook(url, certificate, ...)', 'set_webhook(url, opts)')
            local args = {...}
            return v3_set_webhook(url, {
                certificate = opts_or_cert,
                max_connections = args[1],
                allowed_updates = args[2]
            })
        end
        return v3_set_webhook(url, opts_or_cert)
    end

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    local v3_send_message = api.send_message
    function api.send_message(chat_id, text, third, ...)
        -- v3 style: opts table or nil with no trailing args
        if type(third) == 'table' then
            return v3_send_message(chat_id, text, third)
        end
        -- v2 shorthand: parse_mode as 3rd arg (e.g. send_message(id, text, 'HTML'))
        if type(third) == 'string' or type(third) == 'boolean' then
            deprecation_warning('send_message(positional args)', 'send_message(chat_id, text, opts)')
            local args = {...}
            local link_preview_options
            if args[1] then link_preview_options = { is_disabled = true } end
            local reply_parameters
            if args[3] then reply_parameters = api.reply_parameters(args[3]) end
            return v3_send_message(chat_id, text, {
                parse_mode = third,
                link_preview_options = link_preview_options,
                disable_notification = args[2],
                reply_parameters = reply_parameters,
                reply_markup = args[4] or args[5] or args[6] or args[7] or args[8]
            })
        end
        -- v2 full positional: 3rd arg is message_thread_id (number/nil) + more args
        local nargs = select('#', ...)
        if nargs > 0 or type(third) == 'number' then
            deprecation_warning('send_message(positional args)', 'send_message(chat_id, text, opts)')
            local args = {...}
            local parse_mode = args[1]
            local entities = args[2]
            local link_preview_options = args[3]
            local disable_notification = args[4]
            local protect_content = args[5]
            local reply_parameters = args[6]
            local reply_markup = args[7]
            return v3_send_message(chat_id, text, {
                message_thread_id = third,
                parse_mode = parse_mode,
                entities = entities,
                link_preview_options = link_preview_options,
                disable_notification = disable_notification,
                protect_content = protect_content,
                reply_parameters = reply_parameters,
                reply_markup = reply_markup
            })
        end
        -- v3 with nil opts
        return v3_send_message(chat_id, text, third)
    end

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    local v3_answer_callback_query = api.answer_callback_query
    function api.answer_callback_query(callback_query_id, opts_or_text, ...)
        if type(opts_or_text) == 'string' then
            deprecation_warning('answer_callback_query(positional args)', 'answer_callback_query(id, opts)')
            local args = {...}
            return v3_answer_callback_query(callback_query_id, {
                text = opts_or_text,
                show_alert = args[1],
                url = args[2],
                cache_time = args[3]
            })
        end
        return v3_answer_callback_query(callback_query_id, opts_or_text)
    end

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    local v3_edit_message_text = api.edit_message_text
    function api.edit_message_text(chat_id, message_id, text, opts_or_parse_mode, ...)
        if type(opts_or_parse_mode) == 'string' or type(opts_or_parse_mode) == 'boolean' then
            deprecation_warning('edit_message_text(positional args)', 'edit_message_text(chat_id, message_id, text, opts)')
            local parse_mode = opts_or_parse_mode
            local args = {...}
            local link_preview_options
            if args[1] then link_preview_options = { is_disabled = true } end
            return v3_edit_message_text(chat_id, message_id, text, {
                parse_mode = parse_mode,
                link_preview_options = link_preview_options,
                reply_markup = args[2],
                inline_message_id = args[3]
            })
        end
        return v3_edit_message_text(chat_id, message_id, text, opts_or_parse_mode)
    end

    ---------------------------------------------------------------------------
    -- Media method shims
    -- v2 pattern: send_X(chat_id, media, message_thread_id, ..., positional args)
    -- v3 pattern: send_X(chat_id, media, opts)
    -- Detection: if 3rd arg is not a table, it's v2 positional style.
    ---------------------------------------------------------------------------

    local v3_send_photo = api.send_photo
    function api.send_photo(chat_id, photo, third, ...)
        if type(third) ~= 'table' and (type(third) ~= 'nil' or select('#', ...) > 0) then
            deprecation_warning('send_photo(positional args)', 'send_photo(chat_id, photo, opts)')
            local args = {...}
            return v3_send_photo(chat_id, photo, {
                message_thread_id = third,
                caption = args[1],
                parse_mode = args[2],
                caption_entities = args[3],
                has_spoiler = args[4],
                disable_notification = args[5],
                protect_content = args[6],
                reply_parameters = args[7],
                reply_markup = args[8]
            })
        end
        return v3_send_photo(chat_id, photo, third)
    end

    local v3_send_audio = api.send_audio
    function api.send_audio(chat_id, audio, third, ...)
        if type(third) ~= 'table' and (type(third) ~= 'nil' or select('#', ...) > 0) then
            deprecation_warning('send_audio(positional args)', 'send_audio(chat_id, audio, opts)')
            local args = {...}
            return v3_send_audio(chat_id, audio, {
                message_thread_id = third,
                caption = args[1],
                parse_mode = args[2],
                caption_entities = args[3],
                duration = args[4],
                performer = args[5],
                title = args[6],
                thumbnail = args[7],
                disable_notification = args[8],
                protect_content = args[9],
                reply_parameters = args[10],
                reply_markup = args[11]
            })
        end
        return v3_send_audio(chat_id, audio, third)
    end

    local v3_send_document = api.send_document
    function api.send_document(chat_id, document, third, ...)
        if type(third) ~= 'table' and (type(third) ~= 'nil' or select('#', ...) > 0) then
            deprecation_warning('send_document(positional args)', 'send_document(chat_id, document, opts)')
            local args = {...}
            return v3_send_document(chat_id, document, {
                message_thread_id = third,
                thumbnail = args[1],
                caption = args[2],
                parse_mode = args[3],
                caption_entities = args[4],
                disable_content_type_detection = args[5],
                disable_notification = args[6],
                protect_content = args[7],
                reply_parameters = args[8],
                reply_markup = args[9]
            })
        end
        return v3_send_document(chat_id, document, third)
    end

    local v3_send_video = api.send_video
    function api.send_video(chat_id, video, third, ...)
        if type(third) ~= 'table' and (type(third) ~= 'nil' or select('#', ...) > 0) then
            deprecation_warning('send_video(positional args)', 'send_video(chat_id, video, opts)')
            local args = {...}
            return v3_send_video(chat_id, video, {
                message_thread_id = third,
                duration = args[1],
                width = args[2],
                height = args[3],
                caption = args[4],
                parse_mode = args[5],
                has_spoiler = args[6],
                supports_streaming = args[7],
                disable_notification = args[8],
                protect_content = args[9],
                reply_parameters = args[10],
                reply_markup = args[11]
            })
        end
        return v3_send_video(chat_id, video, third)
    end

    local v3_send_voice = api.send_voice
    function api.send_voice(chat_id, voice, third, ...)
        if type(third) ~= 'table' and (type(third) ~= 'nil' or select('#', ...) > 0) then
            deprecation_warning('send_voice(positional args)', 'send_voice(chat_id, voice, opts)')
            local args = {...}
            return v3_send_voice(chat_id, voice, {
                message_thread_id = third,
                caption = args[1],
                parse_mode = args[2],
                caption_entities = args[3],
                duration = args[4],
                disable_notification = args[5],
                protect_content = args[6],
                reply_parameters = args[7],
                reply_markup = args[8]
            })
        end
        return v3_send_voice(chat_id, voice, third)
    end

    local v3_send_animation = api.send_animation
    function api.send_animation(chat_id, animation, third, ...)
        if type(third) ~= 'table' and (type(third) ~= 'nil' or select('#', ...) > 0) then
            deprecation_warning('send_animation(positional args)', 'send_animation(chat_id, animation, opts)')
            local args = {...}
            return v3_send_animation(chat_id, animation, {
                message_thread_id = third,
                duration = args[1],
                width = args[2],
                height = args[3],
                thumbnail = args[4],
                caption = args[5],
                parse_mode = args[6],
                caption_entities = args[7],
                has_spoiler = args[8],
                disable_notification = args[9],
                protect_content = args[10],
                reply_parameters = args[11],
                reply_markup = args[12]
            })
        end
        return v3_send_animation(chat_id, animation, third)
    end

    local v3_send_sticker = api.send_sticker
    function api.send_sticker(chat_id, sticker, third, ...)
        if type(third) ~= 'table' and (type(third) ~= 'nil' or select('#', ...) > 0) then
            deprecation_warning('send_sticker(positional args)', 'send_sticker(chat_id, sticker, opts)')
            local args = {...}
            return v3_send_sticker(chat_id, sticker, {
                message_thread_id = third,
                emoji = args[1],
                disable_notification = args[2],
                protect_content = args[3],
                reply_parameters = args[4],
                reply_markup = args[5]
            })
        end
        return v3_send_sticker(chat_id, sticker, third)
    end
end
