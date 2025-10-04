# luarrow API Reference

Complete API documentation for luarrow - The Haskell-inspired function composition library for Lua.

## Table of Contents

1. [Quick API Reference](#quick-api-reference)
2. [Complete API Reference](#complete-api-reference)
3. [Basic Examples](#basic-examples)
4. [Real-World Use Cases](#real-world-use-cases)
5. [Advanced Patterns](#advanced-patterns)
6. [Performance Considerations](#performance-considerations)
7. [Type Safety with luaCATS](#type-safety-with-luacats)
8. [Comparison with Other Approaches](#comparison-with-other-approaches)

## 📚 Quick API Reference

### `fun(f)`

Wraps a Lua function into a `Fun` object that supports composition and application.

```lua
local fun = require('luarrow').fun
local wrapped = fun(function(x) return x * 2 end)
```

**Parameters:**
- `f: fun(x: A): B` - Any Lua function

**Returns:**
- `luarrow.Fun<A, B>` - Wrapped function object

### `Fun:compose(g)` or `f * g`

Composes two functions. Returns a new function that applies `g` first, then `f`.

```lua
local f = fun(function(x) return x + 1 end)
local g = fun(function(x) return x * 2 end)

-- Method style
local composed = f:compose(g)

-- Operator style (recommended)
local composed = f * g
```

**Note:** The order follows mathematical notation: `(f ∘ g)(x) = f(g(x))`

### `Fun:apply(x)` or `f % x`

Applies the wrapped function to a value.

```lua
local f = fun(function(x) return x + 1 end)

-- Method style
local result = f:apply(10)

-- Operator style (recommended)
local result = f % 10
```

## 📖 Complete API Reference

### Core Functions

```lua
local fun = require('luarrow').fun

-- Main wrapper function
fun(f)  -- Wraps a function for composition and application
```

### Fun Class

The `luarrow.Fun<A, B>` class represents a wrapped function from type A to type B.

```lua
---@class luarrow.Fun<A, B>
---@field raw fun(x: A): B  -- The original unwrapped function
```

### Methods

```lua
-- Function composition
Fun:compose(g)    -- Compose two functions (f:compose(g) means f ∘ g)

-- Function application
Fun:apply(x)      -- Apply the function to a value
```

### Operators

```lua
-- Composition operator (equivalent to Fun:compose)
f * g             -- Returns luarrow.Fun<A, C> where f: B→C, g: A→B

-- Application operator (equivalent to Fun:apply)
f % x             -- Applies function f to value x
```

## 🎯 Basic Examples

### Simple Composition

```lua
local fun = require('luarrow').fun

-- Define some basic functions
local add_one = function(x) return x + 1 end
local double = function(x) return x * 2 end

-- Compose using operator
local f = fun(add_one) * fun(double)

-- Apply to a value
local result = f % 5
print(result)  -- 11, because add_one(double(5)) = add_one(10) = 11
```

### Method-Style Composition

```lua
-- Using explicit method calls
local f = fun(add_one):compose(fun(double))
local result = f:apply(5)
print(result)  -- 11
```

### Multi-Function Composition

```lua
local add_one = function(x) return x + 1 end
local times_ten = function(x) return x * 10 end
local minus_two = function(x) return x - 2 end
local square = function(x) return x * x end

-- Chain multiple functions
local pipeline = fun(square) * fun(add_one) * fun(times_ten) * fun(minus_two)

local result = pipeline % 42
-- Evaluation order (right to left):
-- minus_two(42) = 40
-- times_ten(40) = 400
-- add_one(400) = 401
-- square(401) = 160801

print(result)  -- 160801
```

## 💡 Real-World Use Cases

### String Processing Pipeline

```lua
local fun = require('luarrow').fun

-- String processing functions
local trim = function(s)
  return s:match("^%s*(.-)%s*$")
end

local lowercase = function(s)
  return s:lower()
end

local remove_special_chars = function(s)
  return s:gsub("[^%w%s]", "")
end

local replace_spaces = function(s)
  return s:gsub("%s+", "_")
end

-- Create a slug generator
local slugify = fun(replace_spaces)
              * fun(remove_special_chars)
              * fun(lowercase)
              * fun(trim)

local title = "  Hello, World! This is Amazing  "
local slug = slugify % title
print(slug)  -- "hello_world_this_is_amazing"
```

### Mathematical Computations

```lua
local fun = require('luarrow').fun

-- Mathematical functions
local square = function(x) return x * x end
local cube = function(x) return x * x * x end
local add = function(n) return function(x) return x + n end end
local multiply = function(n) return function(x) return x * n end end
local negate = function(x) return -x end

-- Polynomial evaluation: -(x³ + 2x² + 3x + 4)
local polynomial = fun(negate)
                 * fun(add(4))
                 * fun(add(3))
                 * fun(multiply(2))
                 * fun(cube)

local result = polynomial % 2
-- cube(2) = 8
-- multiply(2)(8) = 16
-- add(3)(16) = 19
-- add(4)(19) = 23
-- negate(23) = -23

print(result)  -- -23
```

### Data Validation Pipeline

```lua
local fun = require('luarrow').fun

-- Validation functions that return nil on failure
local validate_not_nil = function(x)
  if x == nil then error("Value is nil") end
  return x
end

local validate_number = function(x)
  if type(x) ~= "number" then error("Not a number") end
  return x
end

local validate_positive = function(x)
  if x <= 0 then error("Not positive") end
  return x
end

local validate_range = function(min, max)
  return function(x)
    if x < min or x > max then error("Out of range") end
    return x
  end
end

-- Create a validator for positive numbers in range 1-100
local validate_score = fun(validate_range(1, 100))
                     * fun(validate_positive)
                     * fun(validate_number)
                     * fun(validate_not_nil)

-- Usage
local function safe_validate(validator, value)
  local ok, result = pcall(function() return validator % value end)
  return ok, result
end

local ok1, result1 = safe_validate(validate_score, 50)
print(ok1, result1)  -- true, 50

local ok2, result2 = safe_validate(validate_score, 150)
print(ok2, result2)  -- false, error message

local ok3, result3 = safe_validate(validate_score, -5)
print(ok3, result3)  -- false, error message
```

### List Transformations

```lua
local fun = require('luarrow').fun

-- Higher-order functions for lists
local map = function(f)
  return function(list)
    local result = {}
    for i, v in ipairs(list) do
      result[i] = f(v)
    end
    return result
  end
end

local filter = function(predicate)
  return function(list)
    local result = {}
    for _, v in ipairs(list) do
      if predicate(v) then
        table.insert(result, v)
      end
    end
    return result
  end
end

local reduce = function(f, initial)
  return function(list)
    local acc = initial
    for _, v in ipairs(list) do
      acc = f(acc, v)
    end
    return acc
  end
end

-- Example: Process a list of numbers
local numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

-- Pipeline: filter evens -> double each -> sum
local is_even = function(x) return x % 2 == 0 end
local double = function(x) return x * 2 end
local sum = function(a, b) return a + b end

local process = fun(reduce(sum, 0))
              * fun(map(double))
              * fun(filter(is_even))

local result = process % numbers
-- filter evens: {2, 4, 6, 8, 10}
-- double each: {4, 8, 12, 16, 20}
-- sum: 60

print(result)  -- 60
```

### Configuration Processing

```lua
local fun = require('luarrow').fun
local json = require('json')  -- Assuming a JSON library

-- Configuration processing functions
local parse_json = function(text)
  return json.decode(text)
end

local validate_config = function(config)
  assert(config.host, "Missing host")
  assert(config.port, "Missing port")
  return config
end

local apply_defaults = function(config)
  config.timeout = config.timeout or 30
  config.retries = config.retries or 3
  return config
end

local normalize_host = function(config)
  config.host = config.host:lower()
  return config
end

-- Create config loader
local load_config = fun(normalize_host)
                  * fun(apply_defaults)
                  * fun(validate_config)
                  * fun(parse_json)

-- Usage
local config_text = [[{
  "host": "EXAMPLE.COM",
  "port": 8080
}]]

local config = load_config % config_text
print(config.host)     -- "example.com"
print(config.port)     -- 8080
print(config.timeout)  -- 30
print(config.retries)  -- 3
```

## 🚀 Advanced Patterns

### Partial Application with Composition

```lua
local fun = require('luarrow').fun

-- Create a curried add function
local add = function(a)
  return function(b)
    return a + b
  end
end

local multiply = function(a)
  return function(b)
    return a * b
  end
end

-- Create specialized functions
local add_ten = add(10)
local triple = multiply(3)

-- Compose them
local transform = fun(add_ten) * fun(triple)

local result = transform % 5
print(result)  -- 25, because add_ten(triple(5)) = add_ten(15) = 25
```

### Function Factory Pattern

```lua
local fun = require('luarrow').fun

-- Factory for creating transformation pipelines
local create_normalizer = function(min, max)
  local scale = function(x)
    return (x - min) / (max - min)
  end

  local clamp = function(x)
    if x < 0 then return 0 end
    if x > 1 then return 1 end
    return x
  end

  return fun(clamp) * fun(scale)
end

-- Create a normalizer for 0-100 range
local normalize_percentage = create_normalizer(0, 100)

print(normalize_percentage % 50)   -- 0.5
print(normalize_percentage % 100)  -- 1.0
print(normalize_percentage % 0)    -- 0.0
print(normalize_percentage % 150)  -- 1.0 (clamped)
```

### Monadic-Style Error Handling

```lua
local fun = require('luarrow').fun

-- Result type: {ok: boolean, value: any, error: string}
local Ok = function(value)
  return {ok = true, value = value}
end

local Err = function(error)
  return {ok = false, error = error}
end

-- Lift a function to work with Result type
local lift = function(f)
  return function(result)
    if not result.ok then return result end
    local ok, value = pcall(function() return f(result.value) end)
    if ok then
      return Ok(value)
    else
      return Err(value)
    end
  end
end

-- Example functions
local parse_number = function(s)
  local n = tonumber(s)
  if not n then error("Not a number") end
  return n
end

local validate_positive = function(n)
  if n <= 0 then error("Not positive") end
  return n
end

local double = function(n)
  return n * 2
end

-- Create a safe pipeline
local process = fun(lift(double))
              * fun(lift(validate_positive))
              * fun(lift(parse_number))

-- Usage
local result1 = process % Ok("10")
print(result1.ok, result1.value)  -- true, 20

local result2 = process % Ok("-5")
print(result2.ok, result2.error)  -- false, "Not positive"

local result3 = process % Ok("abc")
print(result3.ok, result3.error)  -- false, "Not a number"
```

### Debugging Pipeline

```lua
local fun = require('luarrow').fun

-- Debug wrapper that logs intermediate values
local debug = function(label)
  return function(x)
    print(string.format("[DEBUG %s]: %s", label, tostring(x)))
    return x
  end
end

-- Create a pipeline with debug points
local add_one = function(x) return x + 1 end
local double = function(x) return x * 2 end
local square = function(x) return x * x end

local pipeline = fun(debug("final"))
               * fun(square)
               * fun(debug("after double"))
               * fun(double)
               * fun(debug("after add_one"))
               * fun(add_one)
               * fun(debug("input"))

local result = pipeline % 5
-- Output:
-- [DEBUG input]: 5
-- [DEBUG after add_one]: 6
-- [DEBUG after double]: 12
-- [DEBUG final]: 144
print("Result:", result)  -- 144
```

### Composition with Side Effects

```lua
local fun = require('luarrow').fun

-- Functions with side effects
local log_to_file = function(filename)
  return function(x)
    local file = io.open(filename, "a")
    file:write(tostring(x) .. "\n")
    file:close()
    return x  -- Pass through the value
  end
end

local increment_counter = function(counter)
  return function(x)
    counter.value = counter.value + 1
    return x
  end
end

-- Create a counter
local counter = {value = 0}

-- Pipeline with side effects
local process = fun(log_to_file("output.log"))
              * fun(increment_counter(counter))
              * fun(function(x) return x * 2 end)

-- Process multiple values
for i = 1, 5 do
  process % i
end

print("Counter:", counter.value)  -- 5
-- output.log contains: 2, 4, 6, 8, 10
```

## ⚡ Performance Considerations

### Overhead Analysis

```lua
local fun = require('luarrow').fun

-- Benchmark: luarrow vs native Lua
local function benchmark(name, f, iterations)
  local start = os.clock()
  for i = 1, iterations do
    f(i)
  end
  local elapsed = os.clock() - start
  print(string.format("%s: %.6f seconds", name, elapsed))
end

local add_one = function(x) return x + 1 end
local double = function(x) return x * 2 end
local square = function(x) return x * x end

-- Native Lua
local native = function(x)
  return square(double(add_one(x)))
end

-- luarrow
local composed = fun(square) * fun(double) * fun(add_one)
local luarrow_fn = function(x)
  return composed % x
end

benchmark("Native Lua", native, 1000000)
benchmark("luarrow", luarrow_fn, 1000000)

-- Note: luarrow has minimal overhead due to simple table wrapping
-- The performance difference is typically negligible for most use cases
```

### When to Use luarrow

**Use luarrow when:**
- Code clarity and maintainability are priorities
- Building complex transformation pipelines
- Working with functional programming patterns
- Composing reusable function components

**Consider native Lua when:**
- Performance is absolutely critical (hot loops)
- Working with simple, one-time transformations
- Interfacing with performance-sensitive C libraries

### Optimization Tips

```lua
-- 1. Pre-compose functions outside loops
local fun = require('luarrow').fun

-- BAD: Composing inside loop
for i = 1, 1000 do
  local f = fun(add_one) * fun(double)  -- Allocates new objects each iteration
  result = f % i
end

-- GOOD: Compose once, reuse
local f = fun(add_one) * fun(double)
for i = 1, 1000 do
  result = f % i
end

-- 2. Use method style for single compositions
-- If you're only composing two functions once, method style is fine
local result = fun(f):compose(fun(g)):apply(x)

-- 3. For very hot paths, consider native Lua
-- If profiling shows composition is a bottleneck, unwrap to native
local function hot_path(x)
  return f(g(h(x)))  -- Direct calls, no wrapper overhead
end
```

## 🏷️ Type Safety with luaCATS

```lua
local fun = require('luarrow').fun

---@type luarrow.Fun<number, number>
local add_one = fun(function(x) return x + 1 end)

---@type luarrow.Fun<number, number>
local double = fun(function(x) return x * 2 end)

---@type luarrow.Fun<number, number>
local composed = add_one * double

-- This will be type-checked by your editor
local result = composed % 10  -- OK: number

-- This would show a type error in editors with luaCATS support
-- local bad = composed % "hello"  -- Error: expected number, got string
```

## 🔄 Comparison with Other Approaches

### vs Pure Lua

```lua
local fun = require('luarrow').fun

-- Pure Lua: Verbose, hard to read
local result = f(g(h(x)))

-- luarrow: Clear, expressive
local result = fun(f) * fun(g) * fun(h) % x
```

### vs Function Chaining

```lua
local fun = require('luarrow').fun

-- Chaining (OOP style): Left-to-right, but limited to methods
local result = x:h():g():f()

-- luarrow: Right-to-left (mathematical), works with any functions
local result = fun(f) * fun(g) * fun(h) % x
```

### vs Lodash-Style

```lua
local fun = require('luarrow').fun

-- Lodash-style (if it existed in Lua)
local result = _.flow(h, g, f)(x)

-- luarrow: More elegant with operators
local result = fun(f) * fun(g) * fun(h) % x
```

## 🎊 Conclusion

luarrow.lua brings the elegance of Haskell's function composition to Lua while maintaining excellent performance and type safety. Whether you're building data pipelines, processing configurations, or creating complex transformations, luarrow.lua makes your code more expressive and maintainable.

**Happy functional programming!** 🚀
