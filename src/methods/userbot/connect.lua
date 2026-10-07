--- Connect using TDLib setNetworkType.
-- @module titogramlua.methods.userbot.connect
-- @usage client:connect(params, callback)
-- @return request ID, or request IDs for batch operations; results are asynchronous
-- @param params TDLib fields: type:NetworkType
-- @param callback optional function(result, err, client)
return require('titogramlua.methods.userbot._support').method('setNetworkType', {['type'] = 'NetworkType'}, nil, {['type'] = {['@type'] = 'networkTypeOther'}})
