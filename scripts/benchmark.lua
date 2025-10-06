-- Benchmark: fun vs arrow vs native Lua
-- Comparing pre-composed vs on-the-fly composition

local fun = require('luarrow.fun').fun
local arrow = require('luarrow.arrow').arrow

-- Test functions
local function f(x)
  return x + 1
end
local function g(x)
  return x * 10
end
local function h(x)
  return x - 2
end

-- Benchmark function
local function benchmark(name, func, iterations)
  local start = os.clock()
  for i = 1, iterations do
    func(i)
  end
  local elapsed = os.clock() - start
  print(string.format('%-35s: %.6f seconds', name, elapsed))
  return elapsed
end

local iterations = 1000000

print(string.format('Running benchmarks with %d iterations...\n', iterations))

-- 1. Native Lua (direct call) vs Fun (pre-composed) vs Arrow (pre-composed)

local native_direct = function(x)
  return h(g(f(x)))
end

local fun_composed = fun(h) * fun(g) * fun(f)
local fun_precomposed = function(x)
  return fun_composed % x
end

local arrow_composed = arrow(f) ^ arrow(g) ^ arrow(h)
local arrow_precomposed = function(x)
  return x % arrow_composed
end

-- 2. Native Lua (on-the-fly) vs Fun (on-the-fly) vs Arrow (on-the-fly)

local native_onthefly = function(x)
  local function native_composed(y)
    return h(g(f(y)))
  end
  return native_composed(x)
end

local fun_onthefly = function(x)
  return fun(h) * fun(g) * fun(f) % x
end

local arrow_onthefly = function(x)
  return x % arrow(f) ^ arrow(g) ^ arrow(h)
end

-- Run benchmarks

print('=== Pre-composed ===')
local native_direct_time = benchmark('Native (direct call)', native_direct, iterations)
local fun_precomposed_time = benchmark('Fun', fun_precomposed, iterations)
local arrow_precomposed_time = benchmark('Arrow', arrow_precomposed, iterations)
print()

print('=== On-the-fly composition ===')
local native_onthefly_time = benchmark('Native', native_onthefly, iterations)
local fun_onthefly_time = benchmark('Fun', fun_onthefly, iterations)
local arrow_onthefly_time = benchmark('Arrow', arrow_onthefly, iterations)
print()

print('=== Overhead compared to native (direct call) ===')
print(string.format('Fun (pre-composed):      %.2fx', fun_precomposed_time / native_direct_time))
print(string.format('Fun (on-the-fly):        %.2fx', fun_onthefly_time / native_direct_time))
print(string.format('Arrow (pre-composed):    %.2fx', arrow_precomposed_time / native_direct_time))
print(string.format('Arrow (on-the-fly):      %.2fx', arrow_onthefly_time / native_direct_time))
print()

print('=== Overhead of on-the-fly vs pre-composed ===')
print(string.format('Native: on-the-fly is    %.2fx slower than direct', native_onthefly_time / native_direct_time))
print(
  string.format('Fun:    on-the-fly is    %.2fx slower than pre-composed', fun_onthefly_time / fun_precomposed_time)
)
print(
  string.format('Arrow:  on-the-fly is    %.2fx slower than pre-composed', arrow_onthefly_time / arrow_precomposed_time)
)
print()

print('\n=== Verifying correctness (input: 42) ===')
print(string.format('Native (direct):     %d', native_direct(42)))
print(string.format('Native (on-the-fly): %d', native_onthefly(42)))
print(string.format('Fun (pre):           %d', fun_precomposed(42)))
print(string.format('Fun (on-the-fly):    %d', fun_onthefly(42)))
print(string.format('Arrow (pre):         %d', arrow_precomposed(42)))
print(string.format('Arrow (on-the-fly):  %d', arrow_onthefly(42)))
print()
