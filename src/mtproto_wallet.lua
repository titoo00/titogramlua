-- Direct Lua MTProto wallet client. No Python process or HTTP bridge is used.
local Client = require('titogramlua.mtproto.client')
local wallet = require('titogramlua.mtproto.wallet_encode')
local objects = require('titogramlua.mtproto.wallet_objects')

local Wallet = {}
Wallet.__index = Wallet

function Wallet.new(options)
    assert(type(options) == 'table', 'MTProto wallet options are required')
    return setmetatable({client = Client.new(options)}, Wallet)
end

function Wallet:connect()
    return self.client:connect()
end

function Wallet:close()
    return self.client:close()
end

function Wallet:is_authorized()
    return self.client:is_authorized()
end

function Wallet:send_code(phone_number)
    return self.client:send_code(phone_number)
end

function Wallet:sign_in(phone_code, phone_code_hash)
    return self.client:sign_in(phone_code, phone_code_hash)
end

function Wallet:sign_up(first_name, last_name, no_joined_notifications)
    return self.client:sign_up(first_name, last_name, no_joined_notifications)
end

function Wallet:check_password(password, parameters)
    return self.client:check_password(password, parameters)
end

function Wallet:save_session(path, password)
    return self.client:save_session(path, password)
end

function Wallet:call(method, params)
    local schema_method
    for name, descriptor in pairs(wallet.methods) do
        if descriptor.name == method then schema_method = name; break end
    end
    assert(schema_method, 'unsupported Telegram wallet method: ' .. tostring(method))
    return self.client:invoke(schema_method, params or {})
end

for name, descriptor in pairs(wallet.methods) do
    Wallet[name] = function(self, params)
        return self.client:invoke(name, params or {})
    end
end

Wallet.methods = wallet.methods
Wallet.objects = objects
Wallet.Client = Client
function Wallet.load_session(options, path, password)
    local client, err = Client.load_session(options, path, password)
    if not client then return nil, err end
    return setmetatable({client = client}, Wallet)
end
return Wallet
