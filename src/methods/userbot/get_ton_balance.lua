--- Get ton balance through TDLib getTonTransactions.
-- @module titogramlua.methods.userbot.get_ton_balance
-- @usage client:get_ton_balance(params, callback)
-- @param params table with TDLib fields: direction:TransactionDirection, offset:string, limit:int32
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('getTonTransactions', {['direction'] = 'TransactionDirection', ['offset'] = 'string', ['limit'] = 'int32'}, {['offset'] = '', ['limit'] = 1}, nil, function(result) return result.gram_amount end)
