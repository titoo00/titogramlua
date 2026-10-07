--- Set the account or a supergroup main profile tab.
-- @module titogramlua.methods.userbot.set_main_profile_tab
-- @param params main_profile_tab ProfileTab; optional supergroup_id selects a supergroup
-- @param callback optional function(result, err, client)
local support = require('titogramlua.methods.userbot._support')
local account = support.method('setMainProfileTab', {main_profile_tab='ProfileTab'})
local group = support.method('setSupergroupMainProfileTab', {supergroup_id='int53', main_profile_tab='ProfileTab'})
return function(self, params, callback)
    assert(type(params) == 'table', 'params must be a table')
    if params.supergroup_id ~= nil then return group(self, params, callback) end
    return account(self, params, callback)
end
