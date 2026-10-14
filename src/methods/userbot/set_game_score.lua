--- Set game score through TDLib setGameScore.
-- @module titogramlua.methods.userbot.set_game_score
-- @usage client:set_game_score(params, callback)
-- @param params table with TDLib fields: chat_id:int53, message_id:int53, edit_message:Bool, user_id:int53, score:int32, force:Bool
-- @param callback optional function(result, err, client); results also arrive in on_update
-- @return TDLib request ID; this method is asynchronous
local support = require('titogramlua.methods.userbot._support')
return support.method('setGameScore', {['chat_id'] = 'int53', ['message_id'] = 'int53', ['edit_message'] = 'Bool', ['user_id'] = 'int53', ['score'] = 'int32', ['force'] = 'Bool'}, nil, nil, nil)
