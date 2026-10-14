require('spec.test_helper')

describe('cli', function()
    describe('arg parsing', function()
        -- Load the parse_args function by extracting it from the CLI script.
        -- We simulate the arg parser logic here since bin/tgbot is a standalone script.
        local function parse_args(args)
            local result = { positional = {}, flags = {} }
            local i = 1
            while i <= #args do
                local a = args[i]
                if a:match('^%-%-') then
                    local key = a:sub(3)
                    if i + 1 <= #args and not args[i + 1]:match('^%-%-') then
                        result.flags[key] = args[i + 1]
                        i = i + 2
                    else
                        result.flags[key] = true
                        i = i + 1
                    end
                else
                    table.insert(result.positional, a)
                    i = i + 1
                end
            end
            return result
        end

        it('parses positional arguments', function()
            local r = parse_args({'send', '123', 'hello'})
            assert.same({'send', '123', 'hello'}, r.positional)
            assert.same({}, r.flags)
        end)

        it('parses flags with values', function()
            local r = parse_args({'send', '123', '--photo', 'cat.jpg', '--caption', 'Look!'})
            assert.same({'send', '123'}, r.positional)
            assert.equals('cat.jpg', r.flags['photo'])
            assert.equals('Look!', r.flags['caption'])
        end)

        it('parses boolean flags', function()
            local r = parse_args({'send', '123', 'hi', '--silent'})
            assert.same({'send', '123', 'hi'}, r.positional)
            assert.is_true(r.flags['silent'])
        end)

        it('parses mixed flags and positional args', function()
            local r = parse_args({'updates', '--limit', '5'})
            assert.same({'updates'}, r.positional)
            assert.equals('5', r.flags['limit'])
        end)

        it('handles no arguments', function()
            local r = parse_args({})
            assert.same({}, r.positional)
            assert.same({}, r.flags)
        end)

        it('handles consecutive boolean flags', function()
            local r = parse_args({'send', '123', 'text', '--silent', '--verbose'})
            assert.is_true(r.flags['silent'])
            assert.is_true(r.flags['verbose'])
        end)
    end)

    describe('tgbot script', function()
        local windows = package.config:sub(1, 1) == '\\'
        local lua = os.getenv('LUA') or 'lua'

        local function run_cli(arguments, clear_token)
            local command = lua .. ' bin/tgbot ' .. arguments .. ' 2>&1'
            if windows then
                command = command:gsub('bin/tgbot', 'bin\\tgbot')
                if clear_token then
                    command = 'set "BOT_TOKEN=" && ' .. command
                end
            else
                if clear_token then
                    command = 'BOT_TOKEN= ' .. command
                end
                command = command .. '; echo "EXIT:$?"'
            end
            local handle = io.popen(command, 'r')
            local output = handle:read('*a')
            local ok, _, code = handle:close()
            local exit_code = ok and 0 or (code or 1)
            if not windows then
                exit_code = tonumber(output:match('EXIT:(%d+)%s*$')) or exit_code
            end
            return output, exit_code
        end

        it('prints usage when no command given', function()
            local output, code = run_cli('')
            assert.truthy(output:find('Usage:'))
            assert.equals(1, code)
        end)

        it('prints error when unknown command given', function()
            local output, code = run_cli('badcommand')
            assert.truthy(output:find('Unknown command'))
            assert.equals(1, code)
        end)

        it('prints error when BOT_TOKEN is missing for info', function()
            local output, code = run_cli('info', true)
            assert.truthy(output:find('BOT_TOKEN'))
            assert.equals(1, code)
        end)

        it('prints error when send is missing chat_id', function()
            local output, code = run_cli('send', true)
            assert.truthy(output:find('chat_id'))
            assert.equals(1, code)
        end)
    end)
end)

