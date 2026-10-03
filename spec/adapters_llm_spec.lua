local api = require('spec.test_helper')
local json = require('dkjson')

describe('llm adapter', function()
    describe('module', function()
        it('api.llm exists', function()
            assert.is_table(api.llm)
        end)

        it('has new function', function()
            assert.is_function(api.llm.new)
        end)

        it('requires provider option', function()
            assert.has_error(function()
                api.llm.new({})
            end)
        end)

        it('requires api_key option', function()
            assert.has_error(function()
                api.llm.new({ provider = 'openai' })
            end)
        end)

        it('rejects unsupported providers', function()
            assert.has_error(function()
                api.llm.new({ provider = 'unknown', api_key = 'test' })
            end, 'Unsupported LLM provider: unknown. Supported: openai, anthropic')
        end)
    end)

    describe('openai', function()
        local llm
        local original_http_request

        before_each(function()
            -- Mock the HTTP request function
            original_http_request = api.adapters.http_request
            llm = api.llm.new({
                provider = 'openai',
                api_key = 'sk-test-key',
                model = 'gpt-4o',
            })
        end)

        after_each(function()
            api.adapters.http_request = original_http_request
        end)

        it('creates an instance', function()
            assert.is_truthy(llm)
            assert.equals('openai', llm._provider)
            assert.equals('gpt-4o', llm._model)
        end)

        it('has chat method', function()
            assert.is_function(llm.chat)
        end)

        it('has complete method', function()
            assert.is_function(llm.complete)
        end)

        it('has embed method', function()
            assert.is_function(llm.embed)
        end)

        it('chat sends correct request structure', function()
            local captured_url, captured_opts
            api.adapters.http_request = function(url, opts)
                captured_url = url
                captured_opts = opts
                return json.encode({
                    choices = {{
                        message = { role = 'assistant', content = 'Hello!' },
                        finish_reason = 'stop',
                    }},
                    usage = { prompt_tokens = 5, completion_tokens = 2, total_tokens = 7 }
                }), 200
            end

            local result = llm:chat({
                { role = 'user', content = 'Hi' }
            })

            assert.truthy(captured_url:find('/chat/completions'))
            assert.equals('POST', captured_opts.method)
            assert.truthy(captured_opts.headers['Authorization']:find('sk%-test%-key'))
            assert.equals('application/json', captured_opts.headers['Content-Type'])

            local body = json.decode(captured_opts.body)
            assert.equals('gpt-4o', body.model)
            assert.equals(1, #body.messages)
            assert.equals('user', body.messages[1].role)
        end)

        it('chat returns parsed response', function()
            api.adapters.http_request = function()
                return json.encode({
                    choices = {{
                        message = { role = 'assistant', content = 'The answer is 42.' },
                        finish_reason = 'stop',
                    }},
                    usage = { prompt_tokens = 10, completion_tokens = 5, total_tokens = 15 }
                }), 200
            end

            local result = llm:chat({
                { role = 'user', content = 'What is the meaning of life?' }
            })

            assert.equals('The answer is 42.', result.content)
            assert.equals('assistant', result.role)
            assert.equals('stop', result.finish_reason)
            assert.equals(10, result.usage.prompt_tokens)
            assert.equals(5, result.usage.completion_tokens)
            assert.equals(15, result.usage.total_tokens)
            assert.is_table(result.raw)
        end)

        it('chat passes options', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    choices = {{ message = { content = 'ok' }, finish_reason = 'stop' }},
                    usage = { prompt_tokens = 1, completion_tokens = 1, total_tokens = 2 }
                }), 200
            end

            llm:chat({{ role = 'user', content = 'test' }}, {
                temperature = 0.5,
                max_tokens = 100,
                model = 'gpt-4o-mini',
            })

            assert.equals(0.5, captured_body.temperature)
            assert.equals(100, captured_body.max_tokens)
            assert.equals('gpt-4o-mini', captured_body.model)
        end)

        it('chat handles system message option', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    choices = {{ message = { content = 'ok' }, finish_reason = 'stop' }},
                    usage = {}
                }), 200
            end

            llm:chat({{ role = 'user', content = 'test' }}, {
                system = 'You are a helpful bot.'
            })

            -- System message should be prepended
            assert.equals(2, #captured_body.messages)
            assert.equals('system', captured_body.messages[1].role)
            assert.equals('You are a helpful bot.', captured_body.messages[1].content)
        end)

        it('chat handles API errors', function()
            api.adapters.http_request = function()
                return json.encode({
                    error = { message = 'Rate limit exceeded', type = 'rate_limit_error' }
                }), 429
            end

            local result, err = llm:chat({{ role = 'user', content = 'test' }})
            assert.is_nil(result)
            assert.truthy(tostring(err):find('Rate limit'))
        end)

        it('chat handles HTTP failure', function()
            api.adapters.http_request = function()
                return nil, 'connection refused'
            end

            local result, err = llm:chat({{ role = 'user', content = 'test' }})
            assert.is_nil(result)
            assert.truthy(tostring(err):find('HTTP request failed'))
        end)

        it('complete wraps single message as chat', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    choices = {{ message = { content = 'response' }, finish_reason = 'stop' }},
                    usage = {}
                }), 200
            end

            llm:complete('Hello world')
            assert.equals(1, #captured_body.messages)
            assert.equals('user', captured_body.messages[1].role)
            assert.equals('Hello world', captured_body.messages[1].content)
        end)

        it('embed sends correct request', function()
            local captured_url, captured_body
            api.adapters.http_request = function(url, opts)
                captured_url = url
                captured_body = json.decode(opts.body)
                return json.encode({
                    data = {{ embedding = {0.1, 0.2, 0.3} }},
                    usage = { prompt_tokens = 5, total_tokens = 5 }
                }), 200
            end

            local result = llm:embed('test text')
            assert.truthy(captured_url:find('/embeddings'))
            assert.equals('test text', captured_body.input)
            assert.equals(1, #result.embeddings)
            assert.equals(3, #result.embeddings[1])
        end)

        it('supports custom base_url', function()
            local captured_url
            api.adapters.http_request = function(url, opts)
                captured_url = url
                return json.encode({
                    choices = {{ message = { content = 'ok' }, finish_reason = 'stop' }},
                    usage = {}
                }), 200
            end

            local custom_llm = api.llm.new({
                provider = 'openai',
                api_key = 'test',
                base_url = 'https://my-proxy.example.com/v1',
            })
            custom_llm:chat({{ role = 'user', content = 'test' }})
            assert.truthy(captured_url:find('my%-proxy%.example%.com'))
        end)

        it('uses default model from constructor', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    choices = {{ message = { content = 'ok' }, finish_reason = 'stop' }},
                    usage = {}
                }), 200
            end

            local custom_llm = api.llm.new({
                provider = 'openai',
                api_key = 'test',
                model = 'gpt-3.5-turbo',
            })
            custom_llm:chat({{ role = 'user', content = 'test' }})
            assert.equals('gpt-3.5-turbo', captured_body.model)
        end)
    end)

    describe('anthropic', function()
        local llm
        local original_http_request

        before_each(function()
            original_http_request = api.adapters.http_request
            llm = api.llm.new({
                provider = 'anthropic',
                api_key = 'sk-ant-test-key',
                model = 'claude-sonnet-4-5-20250929',
            })
        end)

        after_each(function()
            api.adapters.http_request = original_http_request
        end)

        it('creates an instance', function()
            assert.is_truthy(llm)
            assert.equals('anthropic', llm._provider)
        end)

        it('chat sends correct headers', function()
            local captured_opts
            api.adapters.http_request = function(url, opts)
                captured_opts = opts
                return json.encode({
                    content = {{ type = 'text', text = 'Hello!' }},
                    role = 'assistant',
                    stop_reason = 'end_turn',
                    usage = { input_tokens = 5, output_tokens = 2 }
                }), 200
            end

            llm:chat({{ role = 'user', content = 'Hi' }})
            assert.equals('sk-ant-test-key', captured_opts.headers['x-api-key'])
            assert.equals('2023-06-01', captured_opts.headers['anthropic-version'])
        end)

        it('chat sends to /messages endpoint', function()
            local captured_url
            api.adapters.http_request = function(url, opts)
                captured_url = url
                return json.encode({
                    content = {{ type = 'text', text = 'ok' }},
                    usage = { input_tokens = 1, output_tokens = 1 }
                }), 200
            end

            llm:chat({{ role = 'user', content = 'test' }})
            assert.truthy(captured_url:find('/messages'))
        end)

        it('chat extracts system message', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    content = {{ type = 'text', text = 'ok' }},
                    usage = { input_tokens = 1, output_tokens = 1 }
                }), 200
            end

            llm:chat({
                { role = 'system', content = 'You are a bot' },
                { role = 'user', content = 'Hi' }
            })

            assert.equals('You are a bot', captured_body.system)
            -- System message should be filtered from messages array
            assert.equals(1, #captured_body.messages)
            assert.equals('user', captured_body.messages[1].role)
        end)

        it('chat returns parsed response', function()
            api.adapters.http_request = function()
                return json.encode({
                    content = {
                        { type = 'text', text = 'Part 1. ' },
                        { type = 'text', text = 'Part 2.' },
                    },
                    role = 'assistant',
                    stop_reason = 'end_turn',
                    usage = { input_tokens = 10, output_tokens = 8 }
                }), 200
            end

            local result = llm:chat({{ role = 'user', content = 'test' }})
            assert.equals('Part 1. Part 2.', result.content)
            assert.equals('assistant', result.role)
            assert.equals('end_turn', result.finish_reason)
            assert.equals(10, result.usage.prompt_tokens)
            assert.equals(8, result.usage.completion_tokens)
            assert.equals(18, result.usage.total_tokens)
        end)

        it('chat handles API errors', function()
            api.adapters.http_request = function()
                return json.encode({
                    error = { message = 'Invalid API key' }
                }), 401
            end

            local result, err = llm:chat({{ role = 'user', content = 'test' }})
            assert.is_nil(result)
            assert.truthy(tostring(err):find('Invalid API key'))
        end)

        it('complete works as shorthand', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    content = {{ type = 'text', text = 'response' }},
                    usage = { input_tokens = 1, output_tokens = 1 }
                }), 200
            end

            llm:complete('Hello')
            assert.equals(1, #captured_body.messages)
            assert.equals('user', captured_body.messages[1].role)
        end)

        it('claude is accepted as provider alias', function()
            local claude = api.llm.new({
                provider = 'claude',
                api_key = 'test',
            })
            assert.equals('anthropic', claude._provider)
        end)

        it('defaults max_tokens to 1024', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    content = {{ type = 'text', text = 'ok' }},
                    usage = { input_tokens = 1, output_tokens = 1 }
                }), 200
            end

            llm:chat({{ role = 'user', content = 'test' }})
            assert.equals(1024, captured_body.max_tokens)
        end)

        it('respects chat_opts max_tokens', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    content = {{ type = 'text', text = 'ok' }},
                    usage = { input_tokens = 1, output_tokens = 1 }
                }), 200
            end

            llm:chat({{ role = 'user', content = 'test' }}, { max_tokens = 500 })
            assert.equals(500, captured_body.max_tokens)
        end)

        it('system option takes precedence over system message', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    content = {{ type = 'text', text = 'ok' }},
                    usage = { input_tokens = 1, output_tokens = 1 }
                }), 200
            end

            llm:chat({
                { role = 'system', content = 'from message' },
                { role = 'user', content = 'test' }
            }, { system = 'from option' })

            assert.equals('from option', captured_body.system)
        end)
    end)

    describe('tool calling', function()
        local original_http_request

        before_each(function()
            original_http_request = api.adapters.http_request
        end)

        after_each(function()
            api.adapters.http_request = original_http_request
        end)

        it('openai includes tools and tool_choice in the request body', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    choices = {{ message = { content = 'ok' }, finish_reason = 'stop' }},
                    usage = {}
                }), 200
            end

            local llm = api.llm.new({ provider = 'openai', api_key = 'k', model = 'gpt-4o' })
            local tools = {{
                type = 'function',
                ['function'] = { name = 'get_weather', description = 'weather' },
            }}
            llm:chat({{ role = 'user', content = 'weather?' }}, {
                tools = tools,
                tool_choice = 'auto',
            })

            assert.is_table(captured_body.tools)
            assert.equals('get_weather', captured_body.tools[1]['function'].name)
            assert.equals('auto', captured_body.tool_choice)
        end)

        it('openai surfaces tool_calls in the response', function()
            api.adapters.http_request = function()
                return json.encode({
                    choices = {{
                        message = {
                            role = 'assistant',
                            content = nil,
                            tool_calls = {{
                                id = 'call_1',
                                type = 'function',
                                ['function'] = { name = 'get_weather', arguments = '{}' },
                            }},
                        },
                        finish_reason = 'tool_calls',
                    }},
                    usage = {}
                }), 200
            end

            local llm = api.llm.new({ provider = 'openai', api_key = 'k' })
            local result = llm:chat({{ role = 'user', content = 'weather?' }})
            assert.is_table(result.tool_calls)
            assert.equals(1, #result.tool_calls)
            assert.equals('get_weather', result.tool_calls[1]['function'].name)
            assert.equals('tool_calls', result.finish_reason)
        end)

        it('anthropic includes tools and tool_choice in the request body', function()
            local captured_body
            api.adapters.http_request = function(url, opts)
                captured_body = json.decode(opts.body)
                return json.encode({
                    content = {{ type = 'text', text = 'ok' }},
                    usage = { input_tokens = 1, output_tokens = 1 }
                }), 200
            end

            local llm = api.llm.new({ provider = 'anthropic', api_key = 'k' })
            local tools = {{ name = 'get_weather', description = 'weather', input_schema = {} }}
            llm:chat({{ role = 'user', content = 'weather?' }}, {
                tools = tools,
                tool_choice = { type = 'auto' },
            })

            assert.is_table(captured_body.tools)
            assert.equals('get_weather', captured_body.tools[1].name)
            assert.equals('auto', captured_body.tool_choice.type)
        end)

        it('anthropic surfaces tool_use blocks as tool_calls and keeps text', function()
            api.adapters.http_request = function()
                return json.encode({
                    content = {
                        { type = 'text', text = 'Let me check. ' },
                        {
                            type = 'tool_use',
                            id = 'toolu_1',
                            name = 'get_weather',
                            input = { city = 'Paris' },
                        },
                    },
                    role = 'assistant',
                    stop_reason = 'tool_use',
                    usage = { input_tokens = 3, output_tokens = 4 }
                }), 200
            end

            local llm = api.llm.new({ provider = 'anthropic', api_key = 'k' })
            local result = llm:chat({{ role = 'user', content = 'weather?' }})
            -- text blocks are concatenated into content
            assert.equals('Let me check. ', result.content)
            -- tool_use blocks are surfaced as tool_calls
            assert.is_table(result.tool_calls)
            assert.equals(1, #result.tool_calls)
            assert.equals('get_weather', result.tool_calls[1].name)
            assert.equals('Paris', result.tool_calls[1].input.city)
            assert.equals('tool_use', result.finish_reason)
        end)

        it('omits tool_calls when the model returns none (openai)', function()
            api.adapters.http_request = function()
                return json.encode({
                    choices = {{ message = { content = 'plain' }, finish_reason = 'stop' }},
                    usage = {}
                }), 200
            end
            local llm = api.llm.new({ provider = 'openai', api_key = 'k' })
            local result = llm:chat({{ role = 'user', content = 'hi' }})
            assert.is_nil(result.tool_calls)
        end)
    end)

    describe('retry on transient errors', function()
        local original_http_request

        before_each(function()
            original_http_request = api.adapters.http_request
        end)

        after_each(function()
            api.adapters.http_request = original_http_request
        end)

        local function counting_sleeper()
            local calls = { n = 0 }
            return function() calls.n = calls.n + 1 end, calls
        end

        it('retries on 429 then succeeds (openai)', function()
            local attempts = 0
            api.adapters.http_request = function()
                attempts = attempts + 1
                if attempts < 2 then
                    return json.encode({ error = { message = 'rate limited' } }), 429
                end
                return json.encode({
                    choices = {{ message = { content = 'recovered' }, finish_reason = 'stop' }},
                    usage = {}
                }), 200
            end

            local sleeper, sleeps = counting_sleeper()
            local llm = api.llm.new({ provider = 'openai', api_key = 'k' })
            local result = llm:chat({{ role = 'user', content = 'hi' }}, { _sleeper = sleeper })
            assert.equals(2, attempts)
            assert.equals(1, sleeps.n)
            assert.equals('recovered', result.content)
        end)

        it('retries on 5xx then succeeds (anthropic)', function()
            local attempts = 0
            api.adapters.http_request = function()
                attempts = attempts + 1
                if attempts < 3 then
                    return nil, 503
                end
                return json.encode({
                    content = {{ type = 'text', text = 'ok' }},
                    usage = { input_tokens = 1, output_tokens = 1 }
                }), 200
            end

            local sleeper = counting_sleeper()
            local llm = api.llm.new({ provider = 'anthropic', api_key = 'k' })
            local result = llm:chat({{ role = 'user', content = 'hi' }}, { _sleeper = sleeper })
            assert.equals(3, attempts)
            assert.equals('ok', result.content)
        end)

        it('retries on nil response (transport failure) then succeeds', function()
            local attempts = 0
            api.adapters.http_request = function()
                attempts = attempts + 1
                if attempts < 2 then
                    return nil, 'connection reset'
                end
                return json.encode({
                    choices = {{ message = { content = 'ok' }, finish_reason = 'stop' }},
                    usage = {}
                }), 200
            end

            local sleeper = counting_sleeper()
            local llm = api.llm.new({ provider = 'openai', api_key = 'k' })
            local result = llm:chat({{ role = 'user', content = 'hi' }}, { _sleeper = sleeper })
            assert.equals(2, attempts)
            assert.equals('ok', result.content)
        end)

        it('does not retry on a non-429 4xx error', function()
            local attempts = 0
            api.adapters.http_request = function()
                attempts = attempts + 1
                return json.encode({ error = { message = 'bad request' } }), 400
            end

            local sleeper, sleeps = counting_sleeper()
            local llm = api.llm.new({ provider = 'openai', api_key = 'k' })
            local result, err = llm:chat({{ role = 'user', content = 'hi' }}, { _sleeper = sleeper })
            assert.is_nil(result)
            assert.truthy(tostring(err):find('bad request'))
            assert.equals(1, attempts)
            assert.equals(0, sleeps.n)
        end)

        it('gives up after the attempt limit on persistent failure', function()
            local attempts = 0
            api.adapters.http_request = function()
                attempts = attempts + 1
                return nil, 500
            end

            local sleeper = counting_sleeper()
            local llm = api.llm.new({ provider = 'openai', api_key = 'k' })
            local result, err = llm:chat({{ role = 'user', content = 'hi' }}, { _sleeper = sleeper })
            assert.is_nil(result)
            assert.truthy(tostring(err):find('HTTP request failed'))
            assert.equals(3, attempts)
        end)
    end)

    describe('no mutation of caller messages', function()
        local original_http_request

        before_each(function()
            original_http_request = api.adapters.http_request
            api.adapters.http_request = function()
                return json.encode({
                    choices = {{ message = { content = 'ok' }, finish_reason = 'stop' }},
                    usage = {},
                    content = {{ type = 'text', text = 'ok' }},
                }), 200
            end
        end)

        after_each(function()
            api.adapters.http_request = original_http_request
        end)

        it('openai does not grow the shared messages array across calls', function()
            local llm = api.llm.new({ provider = 'openai', api_key = 'k' })
            local messages = {{ role = 'user', content = 'hi' }}
            llm:chat(messages, { system = 'you are a bot' })
            llm:chat(messages, { system = 'you are a bot' })
            -- the system prompt must not have been inserted into the caller copy
            assert.equals(1, #messages)
            assert.equals('user', messages[1].role)
        end)

        it('anthropic does not mutate the shared messages array', function()
            local llm = api.llm.new({ provider = 'anthropic', api_key = 'k' })
            local messages = {{ role = 'user', content = 'hi' }}
            llm:chat(messages, { system = 'you are a bot' })
            llm:chat(messages, { system = 'you are a bot' })
            assert.equals(1, #messages)
        end)
    end)

    describe('adapters utility', function()
        it('is_async returns false outside copas', function()
            assert.is_false(api.adapters.is_async())
        end)

        it('http_request function exists', function()
            assert.is_function(api.adapters.http_request)
        end)
    end)
end)
