--- Initialize using TDLib getCurrentState.
-- @module titogramlua.methods.userbot.initialize
-- @usage client:initialize(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: none
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('getCurrentState', {}, nil, nil)
