--- per-chat/user session store with pluggable backends.
-- the default backend is in-memory; api.session.use(backend) swaps it for a
-- redis- or db-backed one (a table with get/set/clear(self, key) methods).
-- @module telegram-bot-lua.session
return function(api)
    api.session = {}

    -- derive (chat_id, user_id) from an update, a wrapped payload, or a message.
    local function ids(obj)
        if type(obj) ~= 'table' then return nil, nil end
        local payload = obj.message or obj.callback_query or obj.edited_message
            or obj.channel_post or obj.business_message or obj
        local chat = payload.chat or (payload.message and payload.message.chat)
        local from = payload.from
        return chat and chat.id, from and from.id
    end

    --- the stable session key (chat:user) for an update or payload.
    function api.session.key(obj)
        local chat_id, user_id = ids(obj)
        return tostring(chat_id) .. ':' .. tostring(user_id)
    end

    --- create an in-memory session backend.
    function api.session.memory()
        local store = {}
        return {
            get = function(_, key)
                store[key] = store[key] or {}
                return store[key]
            end,
            set = function(_, key, value) store[key] = value end,
            clear = function(_, key) store[key] = nil end,
            _store = store
        }
    end

    api.session._backend = api.session.memory()

    --- replace the session backend.
    function api.session.use(backend)
        api.session._backend = backend
        return api
    end

    --- get the session table for the chat/user in an update.
    function api.session.get(obj)
        return api.session._backend:get(api.session.key(obj))
    end

    --- replace the session value for the chat/user.
    function api.session.set(obj, value)
        return api.session._backend:set(api.session.key(obj), value)
    end

    --- clear the session for the chat/user.
    function api.session.clear(obj)
        return api.session._backend:clear(api.session.key(obj))
    end
end
