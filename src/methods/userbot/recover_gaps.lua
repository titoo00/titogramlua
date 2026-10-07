--- Recover gaps using TDLib getCurrentState.
-- @module titogramlua.methods.userbot.recover_gaps
-- @usage client:recover_gaps(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: none
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('getCurrentState', {}, nil, nil)
