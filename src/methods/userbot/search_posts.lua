--- Search posts through TDLib searchPublicPosts.
-- @module titogramlua.methods.userbot.search_posts
-- @usage client:search_posts(params, callback)
-- @param params table with TDLib fields: query:string, offset:string, limit:int32, star_count:int53
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('searchPublicPosts', {['query'] = 'string', ['offset'] = 'string', ['limit'] = 'int32', ['star_count'] = 'int53'}, nil, nil, nil)
