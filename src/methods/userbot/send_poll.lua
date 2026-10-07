--- Send a TDLib inputMessagePoll message.
-- @module titogramlua.methods.userbot.send_poll
-- @usage client:send_poll(chat_id, content_fields, opts, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param content_fields question:formattedText, options:vector<inputPollOption>, description:formattedText, media:InputPollMedia, is_anonymous:Bool, allows_multiple_answers:Bool, allows_revoting:Bool, members_only:Bool, country_codes:vector<string>, shuffle_options:Bool, hide_results_until_closes:Bool, type:InputPollType, open_period:int32, close_date:int32, is_closed:Bool
-- @param opts topic_id, reply_to, send_options, reply_markup; optional business_connection_id or receiver_user_id
return require('titogramlua.methods.userbot._support').content('inputMessagePoll', {['question'] = 'formattedText', ['options'] = 'vector<inputPollOption>', ['description'] = 'formattedText', ['media'] = 'InputPollMedia', ['is_anonymous'] = 'Bool', ['allows_multiple_answers'] = 'Bool', ['allows_revoting'] = 'Bool', ['members_only'] = 'Bool', ['country_codes'] = 'vector<string>', ['shuffle_options'] = 'Bool', ['hide_results_until_closes'] = 'Bool', ['type'] = 'InputPollType', ['open_period'] = 'int32', ['close_date'] = 'int32', ['is_closed'] = 'Bool'}, nil)
