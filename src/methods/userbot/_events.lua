--- Ordered, filterable TDLib event handlers, with support for callback properties.
-- @module titogramlua.methods.userbot._events
local events = {registrars = {}}
local unpack_values = table.unpack or unpack

function events.add(self, event, callback, opts)
    assert(type(event) == 'string', 'event must be a string')
    assert(type(callback) == 'function', 'callback must be a function')
    if type(opts) == 'number' then opts = {group = opts} end
    opts = opts or {}
    assert(type(opts) == 'table', 'handler options must be a table or group number')
    assert(opts.filter == nil or type(opts.filter) == 'function', 'filter must be a function')
    local group = opts.group or 0
    assert(type(group) == 'number' and group == math.floor(group), 'group must be an integer')
    self._handlers = self._handlers or {}
    self._handler_sequence = (self._handler_sequence or 0) + 1
    local handler = {event = event, callback = callback, filter = opts.filter,
        group = group, sequence = self._handler_sequence}
    self._handlers[#self._handlers + 1] = handler
    table.sort(self._handlers, function(a, b)
        if a.group == b.group then return a.sequence < b.sequence end
        return a.group < b.group
    end)
    return handler
end

function events.registrar(event)
    if events.registrars[event] then return events.registrars[event] end
    local register = function(self, callback, opts) return events.add(self, event, callback, opts) end
    events.registrars[event] = register
    return register
end

function events.emit(self, event, ...)
    local args = {...}
    local count = select('#', ...)
    args[count + 1] = self
    local direct = self['on_' .. event]
    if type(direct) == 'function' and direct ~= events.registrars[event] then
        direct(unpack_values(args, 1, count + 1))
    end
    -- Snapshot: adding/removing handlers during dispatch affects the next event.
    local snapshot = {}
    for _, handler in ipairs(self._handlers or {}) do snapshot[#snapshot + 1] = handler end
    for _, handler in ipairs(snapshot) do
        if handler.event == event and (not handler.filter or handler.filter(args[1], self)) then
            handler.callback(unpack_values(args, 1, count + 1))
        end
    end
end

local update_events = {
    updateBusinessConnection = {'business_connection', 'connection'},
    updateNewBusinessMessage = {'business_message', 'message'},
    updateBusinessMessageEdited = {'edited_business_message'},
    updateBusinessMessagesDeleted = {'deleted_business_messages'},
    updateNewCallbackQuery = {'callback_query'},
    updateNewInlineCallbackQuery = {'callback_query'},
    updateNewBusinessCallbackQuery = {'callback_query'},
    updateChatBoost = {'chat_boost', 'boost'},
    updateNewChatJoinRequest = {'chat_join_request', 'request'},
    updateChatMember = {'chat_member_updated'},
    updateNewChosenInlineResult = {'chosen_inline_result'},
    updateDeleteMessages = {'deleted_messages'},
    updateMessageEdited = {'edited_message'},
    updateMessageContent = {'edited_message'},
    updateNewGuestQuery = {'guest_message', 'message'},
    updateNewInlineQuery = {'inline_query'},
    updateManagedBot = {'managed_bot'},
    updateNewMessage = {'message', 'message'},
    updateMessageReaction = {'message_reaction'},
    updateMessageReactions = {'message_reaction_count'},
    updatePoll = {'poll', 'poll'},
    updateNewPreCheckoutQuery = {'pre_checkout_query'},
    updatePaidMediaPurchased = {'purchased_paid_media'},
    updateNewShippingQuery = {'shipping_query'},
    updateStopMessageDraft = {'stopped_message_generation'},
    updateStory = {'story', 'story'},
    updateStoryDeleted = {'story'},
    updateUserStatus = {'user_status'},
}

function events.dispatch(self, update)
    local kind = update['@type']
    local event = update_events[kind]
    if event then events.emit(self, event[1], event[2] and update[event[2]] or update, update) end
    if kind == 'updateConnectionState' then
        local connected = update.state and update.state['@type'] == 'connectionStateReady'
        if connected and not self._connected then events.emit(self, 'connect', update.state)
        elseif not connected and self._connected then events.emit(self, 'disconnect', update.state) end
        self._connected = connected == true
    end
    events.emit(self, 'raw_update', update)
    events.emit(self, 'update', update)
end

return events
