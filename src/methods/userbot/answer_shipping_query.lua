--- Answer shipping query through TDLib answerShippingQuery.
-- @module titogramlua.methods.userbot.answer_shipping_query
-- @usage client:answer_shipping_query(params, callback)
-- @param params table with TDLib fields: shipping_query_id:int64, shipping_options:vector<shippingOption>, error_message:string
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('answerShippingQuery', {['shipping_query_id'] = 'int64', ['shipping_options'] = 'vector<shippingOption>', ['error_message'] = 'string'}, nil, nil, nil)
