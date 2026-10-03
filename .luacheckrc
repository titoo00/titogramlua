-- mirror the CI lint invocation so `luacheck src/` locally matches CI:
--   luacheck src/ --no-unused-args --no-max-line-length --globals _G _TEST
unused_args = false
max_line_length = false
globals = { "_G", "_TEST" }
