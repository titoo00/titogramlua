--- Search global through TDLib searchMessages.
-- @module titogramlua.methods.userbot.search_global
-- @usage client:search_global(params, callback)
-- @param params table with TDLib fields: chat_list:ChatList, query:string, offset:string, limit:int32, filter:SearchMessagesFilter, chat_type_filter:SearchMessagesChatTypeFilter, min_date:int32, max_date:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('searchMessages', {['chat_list'] = 'ChatList', ['query'] = 'string', ['offset'] = 'string', ['limit'] = 'int32', ['filter'] = 'SearchMessagesFilter', ['chat_type_filter'] = 'SearchMessagesChatTypeFilter', ['min_date'] = 'int32', ['max_date'] = 'int32'}, nil, nil, nil)
