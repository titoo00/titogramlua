local api = require('spec.test_helper')
local json = require('dkjson')

describe('mcp', function()
    before_each(function()
        api._clear_requests()
    end)

    describe('handle()', function()
        it('returns parse error for invalid JSON', function()
            local response = json.decode(api.mcp.handle('not json'))
            assert.equals('2.0', response.jsonrpc)
            assert.equals(-32700, response.error.code)
        end)

        it('returns invalid request for missing method', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0', id = 1
            })))
            assert.equals(-32600, response.error.code)
        end)

        it('returns method not found for unknown methods', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0', id = 1, method = 'unknown/method'
            })))
            assert.equals(-32601, response.error.code)
        end)

        it('handles ping', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0', id = 1, method = 'ping'
            })))
            assert.equals(1, response.id)
            assert.is_table(response.result)
        end)

        it('returns nil for notification messages', function()
            local response = api.mcp.handle(json.encode({
                jsonrpc = '2.0', method = 'notifications/initialized'
            }))
            assert.is_nil(response)
        end)

        it('accepts table input as well as string', function()
            local response = json.decode(api.mcp.handle({
                jsonrpc = '2.0', id = 1, method = 'ping'
            }))
            assert.equals(1, response.id)
            assert.is_table(response.result)
        end)
    end)

    describe('initialize', function()
        it('returns server info and capabilities', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'initialize',
                params = {
                    protocolVersion = '2024-11-05',
                    capabilities = {},
                    clientInfo = { name = 'test', version = '1.0' }
                }
            })))

            assert.equals(1, response.id)
            assert.equals('2024-11-05', response.result.protocolVersion)
            assert.equals('telegram-bot-lua', response.result.serverInfo.name)
            assert.is_table(response.result.capabilities.tools)
            assert.is_table(response.result.capabilities.resources)
        end)
    end)

    describe('tools/list', function()
        it('returns a list of tools with schemas', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0', id = 1, method = 'tools/list'
            })))

            assert.is_table(response.result.tools)
            assert.is_true(#response.result.tools > 0)

            -- Check that send_message tool exists
            local found = false
            for _, tool in ipairs(response.result.tools) do
                if tool.name == 'send_message' then
                    found = true
                    assert.is_string(tool.description)
                    assert.is_table(tool.inputSchema)
                    assert.is_table(tool.inputSchema.properties)
                    assert.is_table(tool.inputSchema.required)
                    break
                end
            end
            assert.is_true(found)
        end)

        it('includes all expected tool names', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0', id = 1, method = 'tools/list'
            })))

            local names = {}
            for _, tool in ipairs(response.result.tools) do
                names[tool.name] = true
            end

            assert.is_true(names['send_message'])
            assert.is_true(names['send_photo'])
            assert.is_true(names['get_updates'])
            assert.is_true(names['get_me'])
            assert.is_true(names['get_chat'])
            assert.is_true(names['ban_chat_member'])
            assert.is_true(names['delete_message'])
            assert.is_true(names['pin_chat_message'])
            assert.is_true(names['answer_callback_query'])
            assert.is_true(names['forward_message'])
        end)
    end)

    describe('tools/call', function()
        it('dispatches send_message to api.send_message', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'tools/call',
                params = {
                    name = 'send_message',
                    arguments = { chat_id = '123', text = 'hello' }
                }
            })))

            assert.equals(1, response.id)
            assert.is_table(response.result)
            assert.is_false(response.result.isError)

            -- Check that api.request was called
            local req = api._last_request()
            assert.truthy(req)
            assert.truthy(req.endpoint:find('/sendMessage'))
            assert.equals('123', req.parameters.chat_id)
            assert.equals('hello', req.parameters.text)
        end)

        it('returns error for missing required params', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'tools/call',
                params = {
                    name = 'send_message',
                    arguments = { chat_id = '123' }  -- missing text
                }
            })))

            assert.equals(-32602, response.error.code)
            assert.truthy(response.error.message:find('text'))
        end)

        it('returns error for unknown tool', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'tools/call',
                params = {
                    name = 'nonexistent_tool',
                    arguments = {}
                }
            })))

            assert.equals(-32601, response.error.code)
        end)

        it('dispatches get_me', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'tools/call',
                params = { name = 'get_me', arguments = {} }
            })))

            assert.is_table(response.result)
            local req = api._last_request()
            assert.truthy(req.endpoint:find('/getMe'))
        end)

        it('dispatches ban_chat_member with opts', function()
            api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'tools/call',
                params = {
                    name = 'ban_chat_member',
                    arguments = {
                        chat_id = '-100123',
                        user_id = 456,
                        revoke_messages = true
                    }
                }
            }))

            local req = api._last_request()
            assert.truthy(req.endpoint:find('/banChatMember'))
            assert.equals('-100123', req.parameters.chat_id)
        end)

        it('dispatches delete_message', function()
            api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'tools/call',
                params = {
                    name = 'delete_message',
                    arguments = { chat_id = '123', message_id = 42 }
                }
            }))

            local req = api._last_request()
            assert.truthy(req.endpoint:find('/deleteMessage'))
        end)
    end)

    describe('resources/list', function()
        it('returns resource definitions', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0', id = 1, method = 'resources/list'
            })))

            assert.is_table(response.result.resources)
            assert.is_true(#response.result.resources > 0)

            local found = false
            for _, res in ipairs(response.result.resources) do
                if res.uri == 'telegram://bot/info' then
                    found = true
                    break
                end
            end
            assert.is_true(found)
        end)
    end)

    describe('resources/read', function()
        it('returns bot info for telegram://bot/info', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'resources/read',
                params = { uri = 'telegram://bot/info' }
            })))

            assert.is_table(response.result.contents)
            assert.equals(1, #response.result.contents)
            assert.equals('telegram://bot/info', response.result.contents[1].uri)
            assert.equals('application/json', response.result.contents[1].mimeType)

            local info = json.decode(response.result.contents[1].text)
            assert.equals(123456, info.id)
            assert.equals('TestBot', info.first_name)
        end)

        it('returns error for unknown resource URI', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'resources/read',
                params = { uri = 'telegram://unknown' }
            })))

            assert.equals(-32601, response.error.code)
        end)

        it('returns error when uri is missing', function()
            local response = json.decode(api.mcp.handle(json.encode({
                jsonrpc = '2.0',
                id = 1,
                method = 'resources/read',
                params = {}
            })))

            assert.equals(-32602, response.error.code)
        end)
    end)

    describe('serve()', function()
        local function make_mock_input(lines)
            local iter = ipairs(lines)
            local i = 0
            return {
                lines = function(_)
                    return function()
                        i = i + 1
                        return lines[i]
                    end
                end
            }
        end

        it('processes lines from input and writes to output', function()
            local input = make_mock_input({
                json.encode({ jsonrpc = '2.0', id = 1, method = 'ping' }),
                json.encode({ jsonrpc = '2.0', id = 2, method = 'tools/list' }),
            })

            local output_lines = {}
            api.mcp.serve({
                input = input,
                write = function(data) table.insert(output_lines, data) end,
                flush = function() end,
            })

            assert.equals(2, #output_lines)

            local resp1 = json.decode(output_lines[1]:gsub('\n$', ''))
            assert.equals(1, resp1.id)

            local resp2 = json.decode(output_lines[2]:gsub('\n$', ''))
            assert.equals(2, resp2.id)
            assert.is_table(resp2.result.tools)
        end)

        it('skips empty lines', function()
            local input = make_mock_input({
                '',
                json.encode({ jsonrpc = '2.0', id = 1, method = 'ping' }),
                '',
            })

            local output_lines = {}
            api.mcp.serve({
                input = input,
                write = function(data) table.insert(output_lines, data) end,
                flush = function() end,
            })

            assert.equals(1, #output_lines)
        end)
    end)
end)
