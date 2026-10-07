--- Search posts through TDLib searchPublicPosts.
-- @module titogramlua.methods.userbot.search_posts
-- @usage client:search_posts(params, callback)
-- @param params table with TDLib fields: query:string, offset:string, limit:int32, star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
-- Source API: https://github.com/ahmedahah4/ravengram/blob/75a8fe833a952403900de55ebfa0cfea77f4c430/pyrogram/methods/messages/search_posts.py
local support = require('titogramlua.methods.userbot._support')
return support.method('searchPublicPosts', {['query'] = 'string', ['offset'] = 'string', ['limit'] = 'int32', ['star_count'] = 'int53'}, nil, nil, nil)
