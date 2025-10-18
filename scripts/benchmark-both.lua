-- Benchmark: Run benchmarks with both Lua and LuaJIT
-- This script runs the benchmark with both interpreters and shows comparison

local function run_benchmark_with(interpreter)
  print(string.format('\n========================================'))
  print(string.format('=== Running with %s ===', interpreter))
  print(string.format('========================================\n'))

  local command = string.format("LUA_PATH='./src/?.lua' %s scripts/benchmark.lua", interpreter)
  os.execute(command)
end

print('Luarrow Performance Benchmark')
print('Comparing performance with Lua and LuaJIT')

-- Check if interpreters are available
local lua_available = os.execute('which lua > /dev/null 2>&1') == 0
local luajit_available = os.execute('which luajit > /dev/null 2>&1') == 0

if lua_available then
  run_benchmark_with('lua')
else
  print('\nWarning: lua interpreter not found, skipping Lua benchmark')
end

if luajit_available then
  run_benchmark_with('luajit')
else
  print('\nWarning: luajit interpreter not found, skipping LuaJIT benchmark')
end

if not lua_available and not luajit_available then
  print('\nError: Neither lua nor luajit interpreter found!')
  os.exit(1)
end

print('\n========================================')
print('=== Benchmark Complete ===')
print('========================================')
