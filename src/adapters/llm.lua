--- LLM adapter for OpenAI and Anthropic APIs.
-- @module telegram-bot-lua.adapters.llm
--[[
    LLM adapter for telegram-bot-lua.
    Provides a unified interface for OpenAI and Anthropic APIs.
    Async-first: uses non-blocking HTTP inside copas, sync fallback otherwise.

    Supports tool / function calling and bounded retry on transient errors.

    Usage:
        local llm = api.llm.new({
            provider = 'openai',
            api_key = 'sk-...',
            model = 'gpt-5.5',
        })
        -- or
        local llm = api.llm.new({
            provider = 'anthropic',
            api_key = 'sk-ant-...',
            model = 'claude-opus-4-8',
        })

        local response = llm:chat({
            { role = 'user', content = 'Hello!' }
        })
        -- response.content    -- the text response
        -- response.usage      -- token usage info
        -- response.tool_calls -- tool/function calls requested by the model

        local response = llm:chat({
            { role = 'user', content = 'What is 2+2?' }
        }, { temperature = 0.5, max_tokens = 100 })

        -- tool / function calling
        local response = llm:chat({
            { role = 'user', content = 'What is the weather in Paris?' }
        }, {
            tools = { ... },          -- provider-specific tool definitions
            tool_choice = 'auto',     -- optional
        })
]]

return function(api)
    api.llm = {}

    local json = require('dkjson')

    -- maximum number of http attempts (1 initial + retries) for transient errors
    local MAX_ATTEMPTS = 3

    -- no-op sleeper so tests never block. real callers can supply their own
    -- via self._sleep or chat_opts._sleeper to add a backoff between attempts.
    local function noop_sleep() end

    -- decide whether an http result is worth retrying. retry on a missing
    -- response (transport failure), on 429 (rate limit) and on any 5xx, but
    -- never on other 4xx (those are client errors that will not improve).
    local function is_retryable(response, status)
        if not response then
            return true
        end
        if status == 429 then
            return true
        end
        if type(status) == 'number' and status >= 500 then
            return true
        end
        return false
    end

    -- http request helper with a bounded retry for transient/429/5xx errors.
    -- the sleeper is resolved from chat_opts._sleeper then self._sleep then a
    -- no-op, so tests can assert attempt counts without real delays.
    local function http_request_with_retry(self, chat_opts, url, opts)
        local sleeper = (chat_opts and chat_opts._sleeper) or self._sleep or noop_sleep
        local response, status, resp_headers
        for attempt = 1, MAX_ATTEMPTS do
            response, status, resp_headers = api.adapters.http_request(url, opts)
            if not is_retryable(response, status) then
                return response, status, resp_headers, attempt
            end
            if attempt < MAX_ATTEMPTS then
                -- short, attempt-scaled backoff (no-op in tests)
                sleeper(attempt)
            end
        end
        return response, status, resp_headers, MAX_ATTEMPTS
    end

    --- create a new LLM client instance.
    -- @param opts table provider configuration options
    -- @param opts.provider string LLM provider: 'openai' or 'anthropic'
    -- @param opts.api_key string API key for the provider
    -- @param opts.model string model name (default varies by provider)
    -- @param opts.base_url string custom API base URL
    -- @return table LLM instance with chat, complete, and embed methods
    function api.llm.new(opts)
        assert(opts and opts.provider, 'llm.new requires a provider option (openai, anthropic)')
        assert(opts.api_key, 'llm.new requires an api_key option')

        local provider = opts.provider:lower()

        if provider == 'openai' then
            return api.llm._new_openai(opts)
        elseif provider == 'anthropic' or provider == 'claude' then
            return api.llm._new_anthropic(opts)
        else
            error('Unsupported LLM provider: ' .. tostring(opts.provider) .. '. Supported: openai, anthropic')
        end
    end

    -- OpenAI-compatible provider --

    function api.llm._new_openai(opts)
        local instance = {
            _provider = 'openai',
            _api_key = opts.api_key,
            _model = opts.model or 'gpt-5.5',
            _base_url = opts.base_url or 'https://api.openai.com/v1',
            _default_opts = opts.defaults or {},
        }

        function instance:chat(messages, chat_opts)
            chat_opts = chat_opts or {}

            -- build a local copy of the messages so a system prompt is never
            -- inserted into the caller's array (which would accumulate across
            -- repeated calls that share the same messages table).
            local request_messages = {}
            if chat_opts.system then
                request_messages[#request_messages + 1] =
                    { role = 'system', content = chat_opts.system }
            end
            for _, msg in ipairs(messages) do
                request_messages[#request_messages + 1] = msg
            end

            local request_body = {
                model = chat_opts.model or self._model,
                messages = request_messages,
                temperature = chat_opts.temperature or self._default_opts.temperature,
                max_tokens = chat_opts.max_tokens or self._default_opts.max_tokens,
                top_p = chat_opts.top_p or self._default_opts.top_p,
                frequency_penalty = chat_opts.frequency_penalty,
                presence_penalty = chat_opts.presence_penalty,
                stop = chat_opts.stop,
            }

            -- tool / function calling: pass tools and an optional tool_choice
            -- straight through in the openai schema.
            if chat_opts.tools then
                request_body.tools = chat_opts.tools
                request_body.tool_choice = chat_opts.tool_choice
            end

            local body = json.encode(request_body)
            local response, status = http_request_with_retry(self, chat_opts,
                self._base_url .. '/chat/completions', {
                method = 'POST',
                headers = {
                    ['Content-Type'] = 'application/json',
                    ['Authorization'] = 'Bearer ' .. self._api_key,
                },
                body = body,
            })

            if not response then
                return nil, 'HTTP request failed: ' .. tostring(status)
            end

            local data = json.decode(response)
            if not data then
                return nil, 'Failed to parse response JSON'
            end

            if data.error then
                return nil, data.error.message or 'OpenAI API error'
            end

            local choice = data.choices and data.choices[1]
            if not choice then
                return nil, 'No response choices returned'
            end

            return {
                content = choice.message and choice.message.content or '',
                role = choice.message and choice.message.role or 'assistant',
                finish_reason = choice.finish_reason,
                tool_calls = choice.message and choice.message.tool_calls,
                usage = data.usage and {
                    prompt_tokens = data.usage.prompt_tokens,
                    completion_tokens = data.usage.completion_tokens,
                    total_tokens = data.usage.total_tokens,
                },
                raw = data,
            }
        end

        function instance:complete(prompt, complete_opts)
            return self:chat({{ role = 'user', content = prompt }}, complete_opts)
        end

        function instance:embed(input, embed_opts)
            embed_opts = embed_opts or {}
            local request_body = {
                model = embed_opts.model or 'text-embedding-3-small',
                input = input,
            }

            local body = json.encode(request_body)
            local response, status = http_request_with_retry(self, embed_opts,
                self._base_url .. '/embeddings', {
                method = 'POST',
                headers = {
                    ['Content-Type'] = 'application/json',
                    ['Authorization'] = 'Bearer ' .. self._api_key,
                },
                body = body,
            })

            if not response then
                return nil, 'HTTP request failed: ' .. tostring(status)
            end

            local data = json.decode(response)
            if not data then
                return nil, 'Failed to parse response JSON'
            end

            if data.error then
                return nil, data.error.message or 'OpenAI API error'
            end

            local vectors = {}
            if data.data then
                for _, item in ipairs(data.data) do
                    vectors[#vectors + 1] = item.embedding
                end
            end

            return {
                embeddings = vectors,
                usage = data.usage,
                raw = data,
            }
        end

        return instance
    end

    -- Anthropic (Claude) provider --

    function api.llm._new_anthropic(opts)
        local instance = {
            _provider = 'anthropic',
            _api_key = opts.api_key,
            _model = opts.model or 'claude-opus-4-8',
            _base_url = opts.base_url or 'https://api.anthropic.com/v1',
            _default_opts = opts.defaults or {},
        }

        function instance:chat(messages, chat_opts)
            chat_opts = chat_opts or {}

            -- Extract system message if present
            local system_msg = chat_opts.system
            local filtered_messages = {}
            for _, msg in ipairs(messages) do
                if msg.role == 'system' then
                    system_msg = system_msg or msg.content
                else
                    filtered_messages[#filtered_messages + 1] = msg
                end
            end

            local request_body = {
                model = chat_opts.model or self._model,
                messages = filtered_messages,
                max_tokens = chat_opts.max_tokens or self._default_opts.max_tokens or 1024,
                temperature = chat_opts.temperature or self._default_opts.temperature,
                top_p = chat_opts.top_p or self._default_opts.top_p,
                stop_sequences = chat_opts.stop,
            }

            if system_msg then
                request_body.system = system_msg
            end

            -- tool / function calling: pass tools and an optional tool_choice
            -- in the anthropic schema.
            if chat_opts.tools then
                request_body.tools = chat_opts.tools
                request_body.tool_choice = chat_opts.tool_choice
            end

            local body = json.encode(request_body)
            local response, status = http_request_with_retry(self, chat_opts,
                self._base_url .. '/messages', {
                method = 'POST',
                headers = {
                    ['Content-Type'] = 'application/json',
                    ['x-api-key'] = self._api_key,
                    ['anthropic-version'] = '2023-06-01',
                },
                body = body,
            })

            if not response then
                return nil, 'HTTP request failed: ' .. tostring(status)
            end

            local data = json.decode(response)
            if not data then
                return nil, 'Failed to parse response JSON'
            end

            if data.error then
                return nil, data.error.message or 'Anthropic API error'
            end

            -- the content is an array of blocks: concatenate the text blocks
            -- and surface the tool_use blocks separately as tool_calls.
            local text_parts = {}
            local tool_calls = nil
            if data.content then
                for _, block in ipairs(data.content) do
                    if block.type == 'text' then
                        text_parts[#text_parts + 1] = block.text
                    elseif block.type == 'tool_use' then
                        tool_calls = tool_calls or {}
                        tool_calls[#tool_calls + 1] = block
                    end
                end
            end

            return {
                content = table.concat(text_parts, ''),
                role = data.role or 'assistant',
                finish_reason = data.stop_reason,
                tool_calls = tool_calls,
                usage = data.usage and {
                    prompt_tokens = data.usage.input_tokens,
                    completion_tokens = data.usage.output_tokens,
                    total_tokens = (data.usage.input_tokens or 0) + (data.usage.output_tokens or 0),
                },
                raw = data,
            }
        end

        function instance:complete(prompt, complete_opts)
            return self:chat({{ role = 'user', content = prompt }}, complete_opts)
        end

        return instance
    end
end
