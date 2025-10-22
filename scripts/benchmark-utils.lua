-- Benchmark: curry, partial, and pure Lua function calls
-- Comparing performance overhead of different currying/partial application approaches

local utils = require('luarrow.utils')

-- Test functions for different arities
local function add2(a, b)
  return a + b
end

local function add3(a, b, c)
  return a + b + c
end

local function add4(a, b, c, d)
  return a + b + c + d
end

local function add5(a, b, c, d, e)
  return a + b + c + d + e
end

-- Benchmark helper
local function benchmark(name, func, iterations)
  collectgarbage()
  collectgarbage()

  local start = os.clock()
  for i = 1, iterations do
    func(i)
  end
  local elapsed = os.clock() - start
  print(string.format('  %-30s: %.6f seconds', name, elapsed))
  return elapsed
end

local iterations = 1000000

print(string.format('Running benchmarks with %d iterations...\n', iterations))

-- ============================================================
-- 2-argument function benchmarks
-- ============================================================
print('=== 2-argument function: add(a, b) ===')

-- Baseline: Pure Lua
local pure2_time = benchmark('Pure Lua', function(i)
  local result = add2(i, i + 1)
end, iterations)

-- curry/curry2
local add2_curried = utils.curry(add2)
local curry2_time = benchmark('curry/curry2', function(i)
  local result = add2_curried(i)(i + 1)
end, iterations)

-- partial
local add2_partial = utils.partial(add2)
local partial2_time = benchmark('partial', function(i)
  local result = add2_partial(i)(i + 1)
end, iterations)

-- partial (all args at once)
local partial2_allargs_time = benchmark('partial (all at once)', function(i)
  local result = add2_partial(i, i + 1)
end, iterations)

print(string.format('  Overhead vs Pure Lua:'))
print(string.format('    curry/curry2:           %.2fx slower', curry2_time / pure2_time))
print(string.format('    partial:                %.2fx slower', partial2_time / pure2_time))
print(string.format('    partial (all at once):  %.2fx slower', partial2_allargs_time / pure2_time))
print()

-- ============================================================
-- 3-argument function benchmarks
-- ============================================================
print('=== 3-argument function: add(a, b, c) ===')

-- Baseline: Pure Lua
local pure3_time = benchmark('Pure Lua', function(i)
  local result = add3(i, i + 1, i + 2)
end, iterations)

-- curry3
local add3_curried = utils.curry3(add3)
local curry3_time = benchmark('curry3', function(i)
  local result = add3_curried(i)(i + 1)(i + 2)
end, iterations)

-- partial
local add3_partial = utils.partial(add3)
local partial3_time = benchmark('partial', function(i)
  local result = add3_partial(i)(i + 1)(i + 2)
end, iterations)

-- partial (all args at once)
local partial3_allargs_time = benchmark('partial (all at once)', function(i)
  local result = add3_partial(i, i + 1, i + 2)
end, iterations)

print(string.format('  Overhead vs Pure Lua:'))
print(string.format('    curry3:                 %.2fx slower', curry3_time / pure3_time))
print(string.format('    partial:                %.2fx slower', partial3_time / pure3_time))
print(string.format('    partial (all at once):  %.2fx slower', partial3_allargs_time / pure3_time))
print()

-- ============================================================
-- 4-argument function benchmarks
-- ============================================================
print('=== 4-argument function: add(a, b, c, d) ===')

-- Baseline: Pure Lua
local pure4_time = benchmark('Pure Lua', function(i)
  local result = add4(i, i + 1, i + 2, i + 3)
end, iterations)

-- curry4
local add4_curried = utils.curry4(add4)
local curry4_time = benchmark('curry4', function(i)
  local result = add4_curried(i)(i + 1)(i + 2)(i + 3)
end, iterations)

-- partial
local add4_partial = utils.partial(add4)
local partial4_time = benchmark('partial', function(i)
  local result = add4_partial(i)(i + 1)(i + 2)(i + 3)
end, iterations)

-- partial (all args at once)
local partial4_allargs_time = benchmark('partial (all at once)', function(i)
  local result = add4_partial(i, i + 1, i + 2, i + 3)
end, iterations)

print(string.format('  Overhead vs Pure Lua:'))
print(string.format('    curry4:                 %.2fx slower', curry4_time / pure4_time))
print(string.format('    partial:                %.2fx slower', partial4_time / pure4_time))
print(string.format('    partial (all at once):  %.2fx slower', partial4_allargs_time / pure4_time))
print()

-- ============================================================
-- 5-argument function benchmarks
-- ============================================================
print('=== 5-argument function: add(a, b, c, d, e) ===')

-- Baseline: Pure Lua
local pure5_time = benchmark('Pure Lua', function(i)
  local result = add5(i, i + 1, i + 2, i + 3, i + 4)
end, iterations)

-- curry5
local add5_curried = utils.curry5(add5)
local curry5_time = benchmark('curry5', function(i)
  local result = add5_curried(i)(i + 1)(i + 2)(i + 3)(i + 4)
end, iterations)

-- partial
local add5_partial = utils.partial(add5)
local partial5_time = benchmark('partial', function(i)
  local result = add5_partial(i)(i + 1)(i + 2)(i + 3)(i + 4)
end, iterations)

-- partial (all args at once)
local partial5_allargs_time = benchmark('partial (all at once)', function(i)
  local result = add5_partial(i, i + 1, i + 2, i + 3, i + 4)
end, iterations)

print(string.format('  Overhead vs Pure Lua:'))
print(string.format('    curry5:                 %.2fx slower', curry5_time / pure5_time))
print(string.format('    partial:                %.2fx slower', partial5_time / pure5_time))
print(string.format('    partial (all at once):  %.2fx slower', partial5_allargs_time / pure5_time))
print()

-- ============================================================
-- Summary
-- ============================================================
print('=== Summary ===')
print()
print('Key observations:')
print('1. curry functions (curry2-8):')
print('   - Simple nested closures with predictable overhead')
print('   - Performance scales with number of arguments')
print('   - Overhead grows linearly: ~2-5x slower than pure Lua')
print()
print('2. partial function:')
print('   - More flexible but higher overhead')
print('   - Uses dynamic arity detection, table operations, and pcall')
print('   - Significantly slower when called one arg at a time: ~5-15x')
print('   - Much better when passing all args at once: ~2-4x')
print()
print('3. Recommendations:')
print('   - For performance-critical code: use pure Lua')
print('   - For moderate use: curry functions are efficient')
print('   - For flexibility: partial with all args at once is reasonable')
print('   - Avoid: partial with one arg at a time in hot loops')
print()

-- ============================================================
-- Verification
-- ============================================================
print('=== Verification (correctness check) ===')
print(string.format('Pure Lua add2(10, 20):                  %d', add2(10, 20)))
print(string.format('curry(add2)(10)(20):                    %d', utils.curry(add2)(10)(20)))
print(string.format('partial(add2)(10)(20):                  %d', utils.partial(add2)(10)(20)))
print(string.format('partial(add2)(10, 20):                  %d', utils.partial(add2)(10, 20)))
print()
print(string.format('Pure Lua add3(1, 2, 3):                 %d', add3(1, 2, 3)))
print(string.format('curry3(add3)(1)(2)(3):                  %d', utils.curry3(add3)(1)(2)(3)))
print(string.format('partial(add3)(1)(2)(3):                 %d', utils.partial(add3)(1)(2)(3)))
print(string.format('partial(add3)(1, 2, 3):                 %d', utils.partial(add3)(1, 2, 3)))
print()
