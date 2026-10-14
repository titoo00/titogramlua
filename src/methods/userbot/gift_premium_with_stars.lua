--- Gift premium with stars through TDLib giftPremiumWithStars.
-- @module titogramlua.methods.userbot.gift_premium_with_stars
-- @usage client:gift_premium_with_stars(params, callback)
-- @param params table with TDLib fields: user_id:int53, star_count:int53, month_count:int32, text:formattedText
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('giftPremiumWithStars', {['user_id'] = 'int53', ['star_count'] = 'int53', ['month_count'] = 'int32', ['text'] = 'formattedText'}, nil, nil, nil)
