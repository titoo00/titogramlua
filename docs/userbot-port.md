# Ravengram method adapters for TDLib

The source snapshot is [Ravengram 75a8fe8](https://github.com/ahmedahah4/ravengram/tree/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods). Its inventory contains 439 names, including the `unbound_arguments` decorator helper. 438 have Lua modules; `export_session_string` is unavailable. The client has 452 public method modules, including its existing TDLib methods. Existing modules are retained rather than duplicated.

This is a TDLib adaptation, not a drop-in replacement for Python/Pyrogram. The new methods take native TDLib parameter tables and return request IDs. Replies require `receive()` or `run()`. The table below records name coverage, not proof of equivalent behavior. No authenticated Telegram integration run has been performed for this port.

## Calling conventions

Direct adapters use `client:method(params, callback)`. Parameters are the fields of the named TDLib function, shown in each module and in [the machine-readable inventory](userbot-methods.json). TDLib objects include `['@type']`; all IDs are TDLib IDs. Unsafe numeric int64 values must be decimal strings. Invalid fields/types are rejected locally; required fields, permissions, limits and nested objects are validated by TDLib. Use a recent TDLib build that exposes the named functions; older builds can return unsupported-method errors.

Callbacks receive `(result, err, client)`. A successful native response can carry `@extra`. Without a callback, direct requests arrive through update callbacks. Composed operations and projected scalar results use `on_result(result, err, operation, client)` when no callback is supplied. Batch operations can return several request IDs. A request ID is not the final result.

```lua
client:get_active_sessions({}, function(result, err)
    if err then print(err.message); return end
    for _, session in ipairs(result.sessions) do print(session.id) end
end)
client:send_reaction({story_poster_chat_id = chat_id, story_id = story_id,
    reaction_type = {['@type'] = 'reactionTypeEmoji', emoji = '❤'},
    update_recent_reactions = true}, function(result, err) end)
-- Call client:receive() repeatedly, or client:run(), to deliver callbacks.
```

Media adapters use `(chat_id, media, opts, callback)`. `media` is an InputFile, a local path, a numeric TDLib file ID, or the documented typed media object. Strings are paths, not Pyrogram file IDs or HTTP downloads. `send_live_photo` requires a video InputFile in `opts.video` or `inputPhoto.video`. Contact/location/venue/dice/checklist/poll/paid-media/rich-message/game/invoice adapters use `(chat_id, content_fields, opts, callback)`; their fields are native InputMessageContent fields. Send options use `opts.send_options`; business/ephemeral routing uses `business_connection_id`/`receiver_user_id` where supported. Existing positional APIs keep their documented signatures.

## Composed and lifecycle operations

- `archive_chats`/`unarchive_chats`: `{chat_ids = {...}}`; topic-by-ID getters accept `chat_id` and their topic ID array.
- `join_chat`: a chat ID, username, invite URL, or its options table. `resolve_peer` resolves a user/chat to a TDLib Chat, not a raw InputPeer.
- `get_media_group`: `{chat_id, message_id}`; only acknowledged cloud message IDs. It gathers same-album messages around the selected message. `copy_media_group`/`forward_media_group`: `{chat_id, from_chat_id, message_id, topic_id?, options?, remove_caption?}`. `send_media_group`: native `sendMessageAlbum` fields with 2–10 InputMessageContent objects.
- `get_chat_members_count` combines chat and group information. `get_chat_online_count`, `get_dialogs_count`, `get_folders` and `get_available_effects` read cached current-state updates; absent state returns error 404. Open/load chats and process updates first. Dialog count is the count known to TDLib; effect results are ID lists.
- `search_posts_count` paginates native public post search and can take multiple requests. Native search eligibility/Stars costs still apply. `send_paid_reaction` adds and commits pending paid reactions.
- `send_phone_number_code`: omit `type` for login, or pass a TDLib PhoneNumberCodeType for other flows. Recovery/resend adapters select authenticated or authentication functions. Do not mix concurrent code flows in one client.
- `save_file`: `{file, file_type?, priority?}` requests preliminary upload. `stream_media`: `{file_id, offset?, limit?, chunk_size?, priority?}`, mandatory callback `(binary_chunk, err, client)`; nil chunk ends the stream, callback returning false stops it. Ranges and limits are bytes. `stop_transmission` cancels a download/upload (`file_id`, optional `upload`) or file generation (`generation_id`). Closing the client discards pending callbacks.
- `start` starts authentication asynchronously and returns the client plus request ID; it does not block for login. `initialize` and `recover_gaps` request current cached state; TDLib manages initialization and update recovery. `connect`/`disconnect` report network availability to TDLib, not socket creation/destruction.
- `restart` closes the old instance, creates and starts a replacement; retain its return value. `terminate` aliases `close`; `idle` aliases `run`. `compose({clients={...}, sequential=false})` pumps several clients, or runs each in order with `sequential=true`.
- `invoke` accepts a native TDLib request table with `@type`, not raw Pyrogram MTProto functions. `unbound_arguments` builds a Lua options table; it is not Python decorator introspection.
- `get_discussion_message` projects the first root message from native thread information. `get_sticker_set` accepts TDLib `set_id`, not a Pyrogram short name. `set_administrator_title` uses the available TDLib chat-member tag operation. `set_main_profile_tab` accepts an optional `supergroup_id`; `send_reaction` selects the story function when `story_id` is supplied.

## Event registration

`client:on_message(callback, {group=0, filter=function(payload, client) return true end})` returns a handler token. `add_handler({event='message', callback=..., group=..., filter=...})` and `remove_handler(token)` support registration management (see their modules). Handlers run in group/registration order; all matching handlers run. Changes during dispatch apply to the next event. This differs from Pyrogram decorator dispatch. Callback properties such as `client.on_message = function(message, update, client) ... end` remain supported.

Payloads are native TDLib objects, not Pyrogram types. Message/story/poll/business connection events unwrap their main object; edits, deletions and query events retain native update structures. Event callbacks receive `(payload, update, client)`; lifecycle start/stop callbacks receive the client. Connection callbacks receive `(state, client)`. `on_raw_update` also sees native request replies, including errors. Handler exceptions propagate; receive-loop cleanup resets its running state.

## Sessions and native features

`export_session_string` is intentionally absent: TDLib stores sessions in its encrypted database and cannot export Ravengram's portable MTProto string session. Reuse the protected database directory and encryption key. No Python backend or runtime dependency was added. Local presence of a method does not grant account permissions: bot-only, business, paid, premium and administrator operations depend on the server and the authenticated account.

## Source name inventory

`existing` means a pre-existing Lua method; its original documented interface remains. `adapted` means a new TDLib adapter. The source signatures are not copied. “Composed / native wrapper” entries have operation-specific conventions described above and in their source module.

### account

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `add_profile_audio` | existing | `addProfileAudio` |
| `get_account_ttl` | existing | `getAccountTtl` |
| `get_global_privacy_settings` | existing | `getArchiveChatListSettings`, `getNewChatPrivacySettings`, `getReadDatePrivacySettings` |
| `get_privacy` | existing | `getUserPrivacySettingRules` |
| `remove_profile_audio` | existing | `removeProfileAudio` |
| `set_account_ttl` | existing | `setAccountTtl` |
| `set_global_privacy_settings` | existing | Composed / native wrapper; see module |
| `set_inactive_session_ttl` | existing | `setInactiveSessionTtl` |
| `set_privacy` | existing | `setUserPrivacySettingRules` |
| `set_profile_audio_position` | existing | `setProfileAudioPosition` |

### advanced

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `invoke` | adapted | Composed / native wrapper; see module |
| `recover_gaps` | adapted | Composed / native wrapper; see module |
| `resolve_peer` | adapted | `createPrivateChat`, `getChat`, `searchPublicChat` |
| `save_file` | adapted | `preliminaryUploadFile` |

### auth

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `accept_terms_of_service` | adapted | `acceptTermsOfService` |
| `change_phone_number` | adapted | `checkPhoneNumberCode` |
| `check_password` | adapted | `checkAuthenticationPassword` |
| `connect` | adapted | Composed / native wrapper; see module |
| `disconnect` | adapted | Composed / native wrapper; see module |
| `get_active_sessions` | adapted | `getActiveSessions` |
| `get_password_hint` | adapted | `getPasswordState` |
| `initialize` | adapted | Composed / native wrapper; see module |
| `log_out` | adapted | `logOut` |
| `recover_password` | adapted | Composed / native wrapper; see module |
| `resend_phone_number_code` | adapted | Composed / native wrapper; see module |
| `reset_session` | adapted | `terminateSession` |
| `reset_sessions` | adapted | `terminateAllOtherSessions` |
| `send_phone_number_code` | adapted | Composed / native wrapper; see module |
| `send_recovery_code` | adapted | Composed / native wrapper; see module |
| `sign_in` | adapted | `checkAuthenticationCode` |
| `sign_in_bot` | adapted | `checkAuthenticationBotToken` |
| `sign_up` | adapted | `registerUser` |
| `terminate` | adapted | Composed / native wrapper; see module |

### bots

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `answer_callback_query` | adapted | `answerCallbackQuery` |
| `answer_chat_join_request_query` | adapted | `answerChatJoinRequestQuery` |
| `answer_guest_query` | adapted | `answerGuestQuery` |
| `answer_inline_query` | adapted | `answerInlineQuery` |
| `answer_pre_checkout_query` | adapted | `answerPreCheckoutQuery` |
| `answer_shipping_query` | adapted | `answerShippingQuery` |
| `answer_web_app_query` | adapted | `answerWebAppQuery` |
| `check_bot_username` | adapted | `checkBotUsername` |
| `create_bot` | adapted | `createBot` |
| `create_invoice_link` | adapted | `createInvoiceLink` |
| `delete_bot_commands` | adapted | `deleteCommands` |
| `delete_ephemeral_message` | adapted | `deleteEphemeralMessage` |
| `edit_ephemeral_message_caption` | adapted | `editEphemeralMessageCaption` |
| `edit_ephemeral_message_media` | adapted | Composed / native wrapper; see module |
| `edit_ephemeral_message_reply_markup` | adapted | `editEphemeralMessage` |
| `edit_ephemeral_message_text` | adapted | `editEphemeralMessage` |
| `edit_user_star_subscription` | adapted | `editUserStarSubscription` |
| `get_bot_commands` | adapted | `getCommands` |
| `get_bot_default_privileges` | adapted | `getMe`, `getUserFullInfo` |
| `get_bot_info_description` | adapted | `getBotInfoDescription` |
| `get_bot_info_short_description` | adapted | `getBotInfoShortDescription` |
| `get_bot_name` | adapted | `getBotName` |
| `get_chat_menu_button` | adapted | `getMenuButton` |
| `get_game_high_scores` | adapted | `getGameHighScores` |
| `get_inline_bot_results` | adapted | `getInlineQueryResults` |
| `get_managed_bot_access_settings` | adapted | `getManagedBotAccessSettings` |
| `get_managed_bot_token` | adapted | `getManagedBotToken` |
| `get_owned_bots` | adapted | `getOwnedBots` |
| `refund_star_payment` | adapted | `refundStarPayment` |
| `replace_managed_bot_token` | adapted | `getManagedBotToken` |
| `request_callback_answer` | adapted | `getCallbackQueryAnswer` |
| `send_chat_join_request_web_app` | adapted | Composed / native wrapper; see module |
| `send_game` | adapted | Composed / native wrapper; see module |
| `send_inline_bot_result` | adapted | `sendInlineQueryResultMessage` |
| `send_invoice` | adapted | Composed / native wrapper; see module |
| `set_bot_commands` | adapted | `setCommands` |
| `set_bot_default_privileges` | adapted | Composed / native wrapper; see module |
| `set_bot_info_description` | adapted | `setBotInfoDescription` |
| `set_bot_info_short_description` | adapted | `setBotInfoShortDescription` |
| `set_bot_name` | adapted | `setBotName` |
| `set_chat_menu_button` | adapted | `setMenuButton` |
| `set_game_score` | adapted | `setGameScore` |
| `set_managed_bot_access_settings` | adapted | `setManagedBotAccessSettings` |

### business

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `delete_business_messages` | adapted | `deleteBusinessMessages` |
| `get_business_account_gifts` | adapted | `getReceivedGifts` |
| `get_business_account_star_balance` | adapted | `getBusinessAccountStarAmount` |
| `get_business_connection` | adapted | `getBusinessConnection` |
| `transfer_business_account_stars` | adapted | `transferBusinessAccountStars` |

### chats

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `add_chat_members` | adapted | `addChatMembers` |
| `archive_chats` | adapted | Composed / native wrapper; see module |
| `ban_chat_member` | adapted | `banChatMember` |
| `close_forum_topic` | adapted | Composed / native wrapper; see module |
| `create_channel` | adapted | Composed / native wrapper; see module |
| `create_folder` | adapted | `createChatFolder` |
| `create_folder_invite_link` | adapted | `createChatFolderInviteLink` |
| `create_forum_topic` | adapted | `createForumTopic` |
| `create_group` | adapted | `createNewBasicGroupChat` |
| `create_supergroup` | adapted | Composed / native wrapper; see module |
| `delete_all_message_reactions` | adapted | `deleteAllRecentMessageReactionsFromSender` |
| `delete_channel` | adapted | `deleteChat` |
| `delete_chat_photo` | adapted | `setChatPhoto` |
| `delete_folder` | adapted | `deleteChatFolder` |
| `delete_folder_invite_link` | adapted | `deleteChatFolderInviteLink` |
| `delete_forum_topic` | adapted | `deleteForumTopic` |
| `delete_message_reaction` | adapted | `deleteMessageReactionsFromSender` |
| `delete_supergroup` | adapted | `deleteChat` |
| `delete_user_history` | adapted | `deleteChatMessagesBySender` |
| `edit_folder` | adapted | `editChatFolder` |
| `edit_folder_invite_link` | adapted | `editChatFolderInviteLink` |
| `edit_forum_topic` | adapted | `editForumTopic` |
| `get_chat` | existing | `getChat` |
| `get_chat_event_log` | adapted | `getChatEventLog` |
| `get_chat_member` | adapted | `getChatMember` |
| `get_chat_members` | adapted | `searchChatMembers` |
| `get_chat_members_count` | adapted | `getChat` |
| `get_chat_online_count` | adapted | Composed / native wrapper; see module |
| `get_chat_settings` | adapted | `getChat` |
| `get_chats_for_folder_invite_link` | adapted | `getChatsForChatFolderInviteLink` |
| `get_dialogs` | adapted | `getChats` |
| `get_dialogs_count` | adapted | Composed / native wrapper; see module |
| `get_direct_messages_topics` | adapted | `loadDirectMessagesChatTopics` |
| `get_direct_messages_topics_by_id` | adapted | Composed / native wrapper; see module |
| `get_folder_invite_links` | adapted | `getChatFolderInviteLinks` |
| `get_folders` | adapted | Composed / native wrapper; see module |
| `get_forum_topics` | adapted | `getForumTopics` |
| `get_forum_topics_by_id` | adapted | Composed / native wrapper; see module |
| `get_personal_channels` | adapted | `getSuitablePersonalChats` |
| `get_send_as_chats` | adapted | `getChatAvailableMessageSenders` |
| `get_similar_channels` | adapted | `getChatSimilarChats` |
| `get_suitable_discussion_chats` | adapted | `getSuitableDiscussionChats` |
| `get_top_chats` | adapted | `getTopChats` |
| `hide_general_forum_topic` | adapted | Composed / native wrapper; see module |
| `join_chat` | adapted | `joinChat`, `joinChatByInviteLink`, `searchPublicChat` |
| `join_folder` | adapted | `addChatFolderByInviteLink` |
| `leave_chat` | adapted | `leaveChat` |
| `leave_folder` | adapted | `deleteChatFolder` |
| `mark_chat_unread` | adapted | Composed / native wrapper; see module |
| `pin_chat_message` | adapted | `pinChatMessage` |
| `pin_forum_topic` | adapted | Composed / native wrapper; see module |
| `process_chat_has_protected_content_disable_request` | adapted | `processChatHasProtectedContentDisableRequest` |
| `promote_chat_member` | adapted | `setChatMemberStatus` |
| `reopen_forum_topic` | adapted | Composed / native wrapper; see module |
| `reorder_folders` | adapted | `reorderChatFolders` |
| `restrict_chat_member` | adapted | `setChatMemberStatus` |
| `set_administrator_title` | adapted | `setChatMemberTag` |
| `set_chat_accent_color` | adapted | `setChatAccentColor` |
| `set_chat_description` | adapted | `setChatDescription` |
| `set_chat_direct_messages_group` | adapted | `setChatDirectMessagesGroup` |
| `set_chat_discussion_group` | adapted | `setChatDiscussionGroup` |
| `set_chat_member_tag` | adapted | `setChatMemberTag` |
| `set_chat_permissions` | adapted | `setChatPermissions` |
| `set_chat_photo` | adapted | `setChatPhoto` |
| `set_chat_profile_accent_color` | adapted | `setChatProfileAccentColor` |
| `set_chat_protected_content` | adapted | `toggleChatHasProtectedContent` |
| `set_chat_title` | adapted | `setChatTitle` |
| `set_chat_ttl` | adapted | `setChatMessageAutoDeleteTime` |
| `set_chat_username` | adapted | `setSupergroupUsername` |
| `set_main_profile_tab` | adapted | `setMainProfileTab`, `setSupergroupMainProfileTab` |
| `set_send_as_chat` | adapted | `setChatMessageSender` |
| `set_slow_mode` | adapted | `setChatSlowModeDelay` |
| `set_upgraded_gift_colors` | adapted | `setUpgradedGiftColors` |
| `toggle_folder_tags` | adapted | `toggleChatFolderTags` |
| `toggle_forum_topics` | adapted | `toggleSupergroupIsForum` |
| `toggle_join_to_send` | adapted | `toggleSupergroupJoinToSendMessages` |
| `transfer_chat_ownership` | adapted | `transferChatOwnership` |
| `unarchive_chats` | adapted | Composed / native wrapper; see module |
| `unban_chat_member` | adapted | Composed / native wrapper; see module |
| `unhide_general_forum_topic` | adapted | Composed / native wrapper; see module |
| `unpin_all_chat_messages` | adapted | `unpinAllChatMessages` |
| `unpin_all_forum_topic_messages` | adapted | `unpinAllForumTopicMessages` |
| `unpin_chat_message` | adapted | `unpinChatMessage` |
| `unpin_forum_topic` | adapted | Composed / native wrapper; see module |
| `update_chat_notifications` | adapted | `setChatNotificationSettings` |

### contacts

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `add_contact` | adapted | `addContact` |
| `delete_contacts` | adapted | `removeContacts` |
| `get_blocked_message_senders` | adapted | `getBlockedMessageSenders` |
| `get_contacts` | adapted | `getContacts` |
| `get_contacts_count` | adapted | `getContacts` |
| `import_contacts` | adapted | `importContacts` |
| `search_contacts` | adapted | `searchContacts` |
| `set_contact_note` | adapted | `setUserNote` |

### decorators

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `on_business_connection` | adapted | Composed / native wrapper; see module |
| `on_business_message` | adapted | Composed / native wrapper; see module |
| `on_callback_query` | adapted | Composed / native wrapper; see module |
| `on_chat_boost` | adapted | Composed / native wrapper; see module |
| `on_chat_join_request` | adapted | Composed / native wrapper; see module |
| `on_chat_member_updated` | adapted | Composed / native wrapper; see module |
| `on_chosen_inline_result` | adapted | Composed / native wrapper; see module |
| `on_connect` | adapted | Composed / native wrapper; see module |
| `on_deleted_business_messages` | adapted | Composed / native wrapper; see module |
| `on_deleted_messages` | adapted | Composed / native wrapper; see module |
| `on_disconnect` | adapted | Composed / native wrapper; see module |
| `on_edited_business_message` | adapted | Composed / native wrapper; see module |
| `on_edited_message` | adapted | Composed / native wrapper; see module |
| `on_error` | adapted | Composed / native wrapper; see module |
| `on_guest_message` | adapted | Composed / native wrapper; see module |
| `on_inline_query` | adapted | Composed / native wrapper; see module |
| `on_managed_bot` | adapted | Composed / native wrapper; see module |
| `on_message` | adapted | Composed / native wrapper; see module |
| `on_message_reaction` | adapted | Composed / native wrapper; see module |
| `on_message_reaction_count` | adapted | Composed / native wrapper; see module |
| `on_poll` | adapted | Composed / native wrapper; see module |
| `on_pre_checkout_query` | adapted | Composed / native wrapper; see module |
| `on_purchased_paid_media` | adapted | Composed / native wrapper; see module |
| `on_raw_update` | adapted | Composed / native wrapper; see module |
| `on_shipping_query` | adapted | Composed / native wrapper; see module |
| `on_start` | adapted | Composed / native wrapper; see module |
| `on_stop` | adapted | Composed / native wrapper; see module |
| `on_stopped_message_generation` | adapted | Composed / native wrapper; see module |
| `on_story` | adapted | Composed / native wrapper; see module |
| `on_user_status` | adapted | Composed / native wrapper; see module |
| `unbound_arguments` | adapted | Composed / native wrapper; see module |

### folders

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `check_chat_folder_invite_link` | adapted | `checkChatFolderInviteLink` |

### invite_links

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `approve_all_chat_join_requests` | adapted | `processChatJoinRequests` |
| `approve_chat_join_request` | adapted | `processChatJoinRequest` |
| `create_chat_invite_link` | adapted | `createChatInviteLink` |
| `decline_all_chat_join_requests` | adapted | `processChatJoinRequests` |
| `decline_chat_join_request` | adapted | `processChatJoinRequest` |
| `delete_chat_admin_invite_links` | adapted | `deleteAllRevokedChatInviteLinks` |
| `delete_chat_invite_link` | adapted | `deleteRevokedChatInviteLink` |
| `edit_chat_invite_link` | adapted | `editChatInviteLink` |
| `export_chat_invite_link` | adapted | `replacePrimaryChatInviteLink` |
| `get_chat_admin_invite_links` | adapted | `getChatInviteLinks` |
| `get_chat_admin_invite_links_count` | adapted | `getChatInviteLinks` |
| `get_chat_admins_with_invite_links` | adapted | `getChatInviteLinkCounts` |
| `get_chat_invite_link` | adapted | `getChatInviteLink` |
| `get_chat_invite_link_joiners` | adapted | `getChatInviteLinkMembers` |
| `get_chat_invite_link_joiners_count` | adapted | `getChatInviteLinkMembers` |
| `get_chat_join_requests` | adapted | `getChatJoinRequests` |
| `revoke_chat_invite_link` | adapted | `revokeChatInviteLink` |

### messages

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `add_checklist_tasks` | adapted | `addChecklistTasks` |
| `add_poll_option` | adapted | `addPollOption` |
| `add_to_gifs` | adapted | `addSavedAnimation` |
| `approve_suggested_post` | adapted | `approveSuggestedPost` |
| `compose_text_with_ai` | adapted | `composeTextWithAi` |
| `copy_media_group` | adapted | Composed / native wrapper; see module |
| `copy_message` | adapted | `forwardMessages` |
| `decline_suggested_post` | adapted | `declineSuggestedPost` |
| `delete_chat_history` | adapted | `deleteChatHistory` |
| `delete_direct_messages_chat_topic_history` | adapted | `deleteDirectMessagesChatTopicHistory` |
| `delete_messages` | existing | `deleteMessages` |
| `delete_poll_option` | adapted | `deletePollOption` |
| `download_media` | adapted | `downloadFile` |
| `edit_inline_caption` | adapted | `editInlineMessageCaption` |
| `edit_inline_media` | adapted | `editInlineMessageMedia` |
| `edit_inline_reply_markup` | adapted | `editInlineMessageReplyMarkup` |
| `edit_inline_text` | adapted | `editInlineMessageText` |
| `edit_message_caption` | adapted | `editMessageCaption` |
| `edit_message_checklist` | adapted | `editMessageChecklist` |
| `edit_message_media` | adapted | `editMessageMedia` |
| `edit_message_reply_markup` | adapted | `editMessageReplyMarkup` |
| `edit_message_text` | existing | `editMessageText` |
| `fix_text_with_ai` | adapted | `fixTextWithAi` |
| `forward_media_group` | adapted | Composed / native wrapper; see module |
| `forward_messages` | adapted | `forwardMessages` |
| `get_available_effects` | adapted | Composed / native wrapper; see module |
| `get_chat_history` | adapted | `getChatHistory` |
| `get_chat_history_count` | adapted | `searchChatMessages` |
| `get_direct_messages_chat_topic_history` | adapted | `getDirectMessagesChatTopicHistory` |
| `get_discussion_message` | adapted | `getMessageThread` |
| `get_discussion_replies` | adapted | `getMessageThreadHistory` |
| `get_discussion_replies_count` | adapted | `getMessageThread` |
| `get_main_web_app` | adapted | `getMainWebApp` |
| `get_media_group` | adapted | `forwardMessages`, `getMessage`, `getMessages` |
| `get_messages` | existing | `getMessages` |
| `get_scheduled_messages` | adapted | `getChatScheduledMessages` |
| `get_user_personal_chat_messages` | adapted | `getPersonalChatHistory` |
| `get_web_app_link_url` | adapted | `getWebAppLinkUrl` |
| `get_web_app_url` | adapted | `getWebAppUrl` |
| `mark_checklist_tasks_as_done` | adapted | `markChecklistTasksAsDone` |
| `open_web_app` | adapted | `openWebApp` |
| `read_chat_history` | adapted | `getChat`, `viewMessages` |
| `read_mentions` | adapted | `readAllChatMentions` |
| `read_reactions` | adapted | `readAllChatReactions` |
| `retract_vote` | adapted | `setPollAnswer` |
| `search_global` | adapted | `searchMessages` |
| `search_global_count` | adapted | `searchMessages` |
| `search_messages` | existing | `searchMessages` |
| `search_messages_count` | adapted | `searchChatMessages` |
| `search_posts` | adapted | `searchPublicPosts` |
| `search_posts_count` | adapted | `searchPublicPosts` |
| `send_animation` | adapted | Composed / native wrapper; see module |
| `send_audio` | adapted | Composed / native wrapper; see module |
| `send_cached_media` | adapted | Composed / native wrapper; see module |
| `send_chat_action` | adapted | `sendChatAction` |
| `send_checklist` | adapted | Composed / native wrapper; see module |
| `send_contact` | adapted | Composed / native wrapper; see module |
| `send_dice` | adapted | Composed / native wrapper; see module |
| `send_document` | adapted | Composed / native wrapper; see module |
| `send_live_photo` | adapted | Composed / native wrapper; see module |
| `send_location` | adapted | Composed / native wrapper; see module |
| `send_media_group` | adapted | `sendMessageAlbum` |
| `send_message` | existing | `sendMessage` |
| `send_message_draft` | adapted | `sendTextMessageDraft` |
| `send_paid_media` | adapted | Composed / native wrapper; see module |
| `send_paid_reaction` | adapted | `addPendingPaidMessageReaction`, `commitPendingPaidMessageReactions` |
| `send_photo` | existing | `sendMessage` |
| `send_poll` | adapted | Composed / native wrapper; see module |
| `send_reaction` | adapted | `setMessageReactions`, `setStoryReaction` |
| `send_rich_message` | adapted | Composed / native wrapper; see module |
| `send_rich_message_draft` | adapted | `sendRichMessageDraft` |
| `send_screenshot_notification` | adapted | `viewMessages` |
| `send_sticker` | adapted | Composed / native wrapper; see module |
| `send_venue` | adapted | Composed / native wrapper; see module |
| `send_video` | adapted | Composed / native wrapper; see module |
| `send_video_note` | adapted | Composed / native wrapper; see module |
| `send_voice` | adapted | Composed / native wrapper; see module |
| `send_web_page` | adapted | Composed / native wrapper; see module |
| `set_direct_messages_chat_topic_is_marked_as_unread` | adapted | `setDirectMessagesChatTopicIsMarkedAsUnread` |
| `start_bot` | adapted | `sendBotStartMessage` |
| `stop_poll` | adapted | `stopPoll` |
| `stream_media` | adapted | `downloadFile`, `readFilePart` |
| `summarize_message` | adapted | `summarizeMessage` |
| `translate_message_text` | adapted | `translateMessageText` |
| `translate_text` | adapted | `translateText` |
| `view_messages` | adapted | `viewMessages` |
| `vote_poll` | adapted | `setPollAnswer` |

### password

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `change_cloud_password` | adapted | `setPassword` |
| `enable_cloud_password` | adapted | Composed / native wrapper; see module |
| `remove_cloud_password` | adapted | `setPassword` |

### payments

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `add_collection_gifts` | adapted | `addGiftCollectionGifts` |
| `apply_gift_code` | adapted | `applyPremiumGiftCode` |
| `buy_gift_upgrade` | adapted | `buyGiftUpgrade` |
| `check_gift_code` | adapted | `checkPremiumGiftCode` |
| `convert_gift_to_stars` | adapted | `sellGift` |
| `craft_gift` | adapted | `craftGift` |
| `create_gift_collection` | adapted | `createGiftCollection` |
| `delete_gift_collection` | adapted | `deleteGiftCollection` |
| `drop_gift_original_details` | adapted | `dropGiftOriginalDetails` |
| `edit_star_subscription` | adapted | `editStarSubscription` |
| `get_available_gifts` | adapted | `getAvailableGifts` |
| `get_chat_gifts` | adapted | `getReceivedGifts` |
| `get_chat_gifts_count` | adapted | `getReceivedGifts` |
| `get_gift_auction_state` | adapted | `getGiftAuctionState` |
| `get_gift_collections` | adapted | `getGiftCollections` |
| `get_gift_upgrade_preview` | adapted | `getGiftUpgradePreview` |
| `get_gift_upgrade_variants` | adapted | `getUpgradedGiftVariants` |
| `get_gifts_for_crafting` | adapted | `getGiftsForCrafting` |
| `get_payment_form` | adapted | `getPaymentForm` |
| `get_stars_balance` | adapted | `getStarTransactions` |
| `get_ton_balance` | adapted | `getTonTransactions` |
| `get_upgraded_gift` | adapted | `getUpgradedGift` |
| `get_upgraded_gift_value_info` | adapted | `getUpgradedGiftValueInfo` |
| `gift_premium_with_stars` | adapted | `giftPremiumWithStars` |
| `hide_gift` | adapted | `toggleGiftIsSaved` |
| `increase_gift_auction_bid` | adapted | `increaseGiftAuctionBid` |
| `place_gift_auction_bid` | adapted | `placeGiftAuctionBid` |
| `process_gift_purchase_offer` | adapted | `processGiftPurchaseOffer` |
| `remove_collection_gifts` | adapted | `removeGiftCollectionGifts` |
| `reorder_collection_gifts` | adapted | `reorderGiftCollectionGifts` |
| `reorder_gift_collections` | adapted | `reorderGiftCollections` |
| `reuse_star_subscription` | adapted | `reuseStarSubscription` |
| `search_gifts_for_resale` | adapted | `searchGiftsForResale` |
| `send_gift` | adapted | `sendGift` |
| `send_gift_purchase_offer` | adapted | `sendGiftPurchaseOffer` |
| `send_payment_form` | adapted | `sendPaymentForm` |
| `send_resold_gift` | adapted | `sendResoldGift` |
| `set_gift_collection_name` | adapted | `setGiftCollectionName` |
| `set_gift_resale_price` | adapted | `setGiftResalePrice` |
| `set_pinned_gifts` | adapted | `setPinnedGifts` |
| `show_gift` | adapted | `toggleGiftIsSaved` |
| `suggest_birthday` | adapted | `suggestUserBirthdate` |
| `transfer_gift` | adapted | `transferGift` |
| `upgrade_gift` | adapted | `upgradeGift` |

### phone

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `get_call_members` | adapted | `getGroupCallParticipants` |

### premium

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `apply_boost` | adapted | `boostChat` |
| `get_boosts` | adapted | `getAvailableChatBoostSlots` |
| `get_boosts_status` | adapted | `getChatBoostStatus` |

### stickers

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `add_favorite_sticker` | adapted | `addFavoriteSticker` |
| `add_recent_sticker` | adapted | `addRecentSticker` |
| `add_sticker_to_set` | adapted | `addStickerToSet` |
| `change_sticker_set` | adapted | `changeStickerSet` |
| `clear_recent_stickers` | adapted | `clearRecentStickers` |
| `create_new_sticker_set` | adapted | `createNewStickerSet` |
| `delete_sticker_from_set` | adapted | `removeStickerFromSet` |
| `delete_sticker_set` | adapted | `deleteStickerSet` |
| `get_custom_emoji_stickers` | adapted | `getCustomEmojiStickers` |
| `get_favorite_stickers` | adapted | `getFavoriteStickers` |
| `get_owned_sticker_sets` | adapted | `getOwnedStickerSets` |
| `get_recent_stickers` | adapted | `getRecentStickers` |
| `get_sticker_set` | adapted | `getStickerSet` |
| `get_suggested_sticker_set_name` | adapted | `getSuggestedStickerSetName` |
| `remove_favorite_sticker` | adapted | `removeFavoriteSticker` |
| `remove_recent_sticker` | adapted | `removeRecentSticker` |
| `reorder_installed_sticker_sets` | adapted | `reorderInstalledStickerSets` |
| `replace_sticker_in_set` | adapted | `replaceStickerInSet` |
| `search_sticker_sets` | adapted | `searchStickerSets` |
| `search_stickers` | adapted | `searchStickers` |
| `set_custom_emoji_sticker_set_thumbnail` | adapted | `setCustomEmojiStickerSetThumbnail` |
| `set_sticker_emoji_list` | adapted | `setStickerEmojis` |
| `set_sticker_keywords` | adapted | `setStickerKeywords` |
| `set_sticker_mask_position` | adapted | `setStickerMaskPosition` |
| `set_sticker_position_in_set` | adapted | `setStickerPositionInSet` |
| `set_sticker_set_thumbnail` | adapted | `setStickerSetThumbnail` |
| `set_sticker_set_title` | adapted | `setStickerSetTitle` |
| `upload_sticker_file` | adapted | `uploadStickerFile` |

### stories

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `can_post_stories` | existing | `canPostStory` |
| `copy_story` | existing | Composed / native wrapper; see module |
| `delete_stories` | existing | Composed / native wrapper; see module |
| `edit_story_caption` | existing | Composed / native wrapper; see module |
| `edit_story_media` | existing | Composed / native wrapper; see module |
| `edit_story_privacy` | existing | Composed / native wrapper; see module |
| `enable_stealth_mode` | existing | `activateStoryStealthMode` |
| `forward_story` | existing | Composed / native wrapper; see module |
| `get_all_stories` | existing | `loadActiveStories` |
| `get_archived_stories` | existing | `getChatArchivedStories` |
| `get_chat_stories` | existing | Composed / native wrapper; see module |
| `get_pinned_stories` | existing | `getChatPostedToChatPageStories` |
| `get_stories` | existing | Composed / native wrapper; see module |
| `get_story_views` | existing | `getStoryInteractions` |
| `hide_chat_stories` | existing | `setChatActiveStoriesList` |
| `pin_chat_stories` | existing | `setChatPinnedStories` |
| `read_chat_stories` | existing | `openStory` |
| `send_story` | existing | Composed / native wrapper; see module |
| `show_chat_stories` | existing | `setChatActiveStoriesList` |
| `unpin_chat_stories` | existing | `getChatPostedToChatPageStories`, `setChatPinnedStories` |
| `view_stories` | existing | `openStory` |

### users

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `block_user` | existing | `setMessageSenderBlockList` |
| `check_username` | existing | `checkChatUsername` |
| `delete_profile_photos` | existing | `deleteProfilePhoto` |
| `get_chat_audios` | existing | `getUserProfileAudios` |
| `get_chat_audios_count` | existing | `getUserProfileAudios` |
| `get_chat_photos` | existing | `getUserProfilePhotos`, `searchChatMessages` |
| `get_chat_photos_count` | existing | `getChatMessageCount`, `getUserProfilePhotos` |
| `get_common_chats` | existing | `getGroupsInCommon` |
| `get_default_emoji_statuses` | existing | `getDefaultEmojiStatuses` |
| `get_me` | existing | `getMe` |
| `get_users` | existing | `getUser` |
| `set_emoji_status` | existing | `setChatEmojiStatus`, `setEmojiStatus` |
| `set_personal_channel` | existing | `setPersonalChat` |
| `set_profile_photo` | existing | `setProfilePhoto` |
| `set_username` | existing | `setUsername` |
| `unblock_user` | existing | `setMessageSenderBlockList` |
| `update_birthday` | existing | `setBirthdate` |
| `update_profile` | existing | `setBio`, `setName` |
| `update_status` | existing | `setOption` |

### utilities

| Source name | Status | TDLib function / implementation |
| --- | --- | --- |
| `add_handler` | adapted | Composed / native wrapper; see module |
| `compose` | adapted | Composed / native wrapper; see module |
| `export_session_string` | unavailable | Unavailable: TDLib database session |
| `idle` | adapted | Composed / native wrapper; see module |
| `remove_handler` | adapted | Composed / native wrapper; see module |
| `restart` | adapted | Composed / native wrapper; see module |
| `run` | existing | Composed / native wrapper; see module |
| `start` | adapted | `getAuthorizationState` |
| `stop` | existing | Composed / native wrapper; see module |
| `stop_transmission` | adapted | Composed / native wrapper; see module |
