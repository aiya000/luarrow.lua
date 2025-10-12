# luarrow Examples

This document provides comprehensive examples of using luarrow, from basic usage to advanced patterns and real-world use cases.

For API reference, see [api.md](api.md).

## Table of Contents

1. [Basic Examples](#-basic-examples)
    - [Pipeline-Style (`Arrow`) Basic Examples](#pipeline-style-arrow-basic-examples)
        - [Operator-Style Pipeline Composition](#operator-style-pipeline-composition)
        - [Method-Style Pipeline Composition](#method-style-pipeline-composition)
        - [Multi-Stage Pipeline](#multi-stage-pipeline)
        - [String Processing Pipeline](#string-processing-pipeline)
    - [Haskell-Style (`Fun`) Basic Examples](#haskell-style-fun-basic-examples)
        - [Operator-Style Composition](#operator-style-composition)
        - [Method-Style Composition](#method-style-composition)
        - [Comparison: Fun vs Arrow](#comparison-fun-vs-arrow)
2. [Real-World Examples](#-real-world-examples)
    - [Pipeline-Style (`Arrow`) Real-World Examples](#pipeline-style-arrow-real-world-examples)
        - [Data Validation Pipeline](#data-validation-pipeline)
        - [List Transformations](#list-transformations)
        - [Configuration Processing](#configuration-processing)
    - [Haskell-Style (`Fun`) Real-World Examples](#haskell-style-fun-real-world-examples)
        - [Multi-Function Composition](#multi-function-composition)
        - [String Processing Pipeline](#string-processing-pipeline-1)
        - [Mathematical Computations](#mathematical-computations)
3. [Advanced Patterns](#-advanced-patterns)
    - [Pipeline-Style (`Arrow`) Advanced Patterns](#pipeline-style-arrow-advanced-patterns)
        - [Debugging Pipeline](#debugging-pipeline)
        - [Composition with Side Effects](#composition-with-side-effects)
    - [Haskell-Style (`Fun`) Advanced Patterns](#haskell-style-fun-advanced-patterns)
        - [Partial Application with Composition](#partial-application-with-composition)
        - [Function Factory Pattern](#function-factory-pattern)
        - [Monadic-Style Error Handling](#monadic-style-error-handling)
4. [Working with LuaCATS](#-working-with-luacats)
5. [Performance Considerations](#-performance-considerations)
    - [Benchmark Results](#benchmark-results)
    - [How to optimize performance](#how-to-optimaize-performance)
6. [Comparison with Other Approaches](#-comparison-with-other-approaches)
    - [vs Pure Lua](#vs-pure-lua)
    - [vs Function Chaining](#vs-function-chaining)
    - [vs Lodash-Style](#vs-lodash-style)
7. [Conclusion](#-conclusion)

## 🎯 Basic Examples

### Pipeline-Style (`Arrow`) Basic Examples

The `arrow` API provides an alternative pipeline-style composition that reads **left-to-right**, similar to:
- Unix pipes (`|`)
- Haskell's `>>>` operator
- Pipeline Operator `|>` in Elm, F#, OCaml, Elixir, and other languages

### Operator-Style Pipeline Composition

Recommended for pipeline-style workflows.

```lua
local arrow = require('luarrow').arrow

-- Define some basic functions
local f = function(x) return x + 1 end
local g = function(x) return x * 2 end

-- Pipeline-style: data flows left-to-right
local result = 5 % arrow(f) ^ arrow(g)
print(result)  -- 12, because g(f(5)) = g(6) = 12
```

### Method-Style Pipeline Composition

Alternative approach using explicit method calls.

```lua
-- Using explicit method calls
local result = arrow(f):compose_to(arrow(g)):apply(5)
print(result)  -- 12
```

### Multi-Stage Pipeline

```lua
local arrow = require('luarrow').arrow

local add_one = function(x) return x + 1 end
local times_ten = function(x) return x * 10 end
local minus_two = function(x) return x - 2 end

-- Pipeline: data flows naturally from left to right
local result = 42 % arrow(add_one) ^ arrow(times_ten) ^ arrow(minus_two)
print(result)  -- 428
-- Evaluation order (left to right):
-- add_one(42) = 43
-- times_ten(43) = 430
-- minus_two(430) = 428
```

### String Processing Pipeline

```lua
local arrow = require('luarrow').arrow

-- String processing functions
local trim = function(s)
  return s:match('^%s*(.-)%s*$')
end

local uppercase = function(s)
  return s:upper()
end

local add_prefix = function(s)
  return 'USER: ' .. s
end

-- Create a user name processor - pipeline reads left-to-right
local username = '  alice  ' % arrow(trim) ^ arrow(uppercase) ^ arrow(add_prefix)
print(username)  -- 'USER: ALICE'
```

### Haskell-Style (`Fun`) Basic Examples

#### Operator-Style Composition

Recommended.

```lua
local fun = require('luarrow').fun

-- Define some basic functions
local f = function(x) return x + 1 end
local g = function(x) return x * 2 end

-- Compose and apply using operator
local result = fun(f) * fun(g) % 5
print(result)  -- 11, because f(g(5)) = f(10) = 11
```

#### Method-Style Composition

Alternative approach using explicit method calls.

```lua
-- Using explicit method calls
local result = fun(f):compose(fun(g)):apply(5)
print(result)  -- 11
```

#### Comparison: Fun vs Arrow

Both `fun` and `arrow` provide the same functionality but with different composition order:

```lua
local fun = require('luarrow').fun
local arrow = require('luarrow').arrow

local f = function(x) return x + 1 end
local g = function(x) return x * 2 end
local h = function(x) return x - 5 end

-- Fun: Mathematical/Haskell style (right-to-left composition)
local result1 = fun(h) * fun(g) * fun(f) % 10
print(result1)  -- 17, because h(g(f(10))) = h(g(11)) = h(22) = 17

-- Arrow: Pipeline/Unix style (left-to-right composition)
local result2 = 10 % arrow(f) ^ arrow(g) ^ arrow(h)
print(result2)  -- 17, because h(g(f(10))) = h(g(11)) = h(22) = 17

-- Both produce the same result, but the syntax reflects different mental models:
-- - fun: Think like mathematics (f ∘ g ∘ h)
-- - arrow: Think like pipelines (data | f | g | h)
```

**When to use which:**
- Use `fun` when thinking in mathematical/Haskell style (function composition)
- Use `arrow` when thinking in pipeline/data-flow style (Unix pipes, Pipeline Operator `|>`, reactive streams)

## 💡 Real-World Examples

### Pipeline-Style (`Arrow`) Real-World Examples

#### Data Validation Pipeline

```lua
local arrow = require('luarrow').arrow

-- Validation functions that return nil on failure
local validate_not_nil = function(x)
  if x == nil then error('Value is nil') end
  return x
end

local validate_number = function(x)
  if type(x) ~= 'number' then error('Not a number') end
  return x
end

local validate_positive = function(x)
  if x <= 0 then error('Not positive') end
  return x
end

local validate_range = function(min, max)
  return function(x)
    if x < min or x > max then error('Out of range') end
    return x
  end
end

-- Create a validator for positive numbers in range 1-100 (pipeline style)
local validate_score = arrow(validate_not_nil)
                     ^ arrow(validate_number)
                     ^ arrow(validate_positive)
                     ^ arrow(validate_range(1, 100))

-- Usage
local function safe_validate(value, validator)
  local ok, result = pcall(function() return value % validator end)
  return ok, result
end

local ok1, result1 = safe_validate(50, validate_score)
print(ok1, result1)  -- true, 50

local ok2, result2 = safe_validate(150, validate_score)
print(ok2, result2)  -- false, error message

local ok3, result3 = safe_validate(-5, validate_score)
print(ok3, result3)  -- false, error message
```

### List Transformations

```lua
local arrow = require('luarrow').arrow

-- Higher-order functions for lists
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

local map = function(f)
  return function(list)
    local result = {}
    for i, v in ipairs(list) do
      result[i] = f(v)
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

-- Pipeline: filter evens -> double each -> sum (left-to-right data flow)
local is_even = function(x) return x % 2 == 0 end
local double = function(x) return x * 2 end
local sum = function(a, b) return a + b end

local result = numbers
             % arrow(filter(is_even))
             ^ arrow(map(double))
             ^ arrow(reduce(sum, 0))
-- filter evens: {2, 4, 6, 8, 10}
-- double each: {4, 8, 12, 16, 20}
-- sum: 60

print(result)  -- 60
```

### Configuration Processing

```lua
local arrow = require('luarrow').arrow
local json = require('json')  -- Assuming a JSON library

-- Configuration processing functions
local parse_json = function(text)
  return json.decode(text)
end

local validate_config = function(config)
  assert(config.host, 'Missing host')
  assert(config.port, 'Missing port')
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

-- Usage (pipeline style: data flows left-to-right)
local config_text = [[{
  'host': 'EXAMPLE.COM',
  'port': 8080
}]]

local config = config_text
             % arrow(parse_json)
             ^ arrow(validate_config)
             ^ arrow(apply_defaults)
             ^ arrow(normalize_host)

print(config.host)     -- 'example.com'
print(config.port)     -- 8080
print(config.timeout)  -- 30
print(config.retries)  -- 3
```

### Haskell-Style (`Fun`) Real-World Examples

#### Multi-Function Composition

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

<a name="about-point-free-style"></a>

> [!Important]
> This definition style for `pipeline` is what Haskell programmers call '**Point-Free Style**'!
> In Haskell, this is a very common technique to reduce the amount of code and improve readability.

> [!TIP]
> Alternatively, you can compose and print in a single expression:
>
> ```lua
> fun(print) * fun(square) * fun(add_one) * fun(times_ten) * fun(minus_two) % 42
> ```
>
> instead of:
>
> ```lua
> local pipeline = fun(square) * fun(add_one) * fun(times_ten) * fun(minus_two)
> local result = pipeline % 42
> print(result)
> ```

#### String Processing Pipeline

```lua
local fun = require('luarrow').fun

-- String processing functions
local trim = function(s)
  return s:match('^%s*(.-)%s*$')
end

local lowercase = function(s)
  return s:lower()
end

local remove_special_chars = function(s)
  return s:gsub('[^%w%s]', '')
end

local replace_spaces = function(s)
  return s:gsub('%s+', '_')
end

-- Create a slug generator - Point-Free-Style function definition
local slugify = fun(replace_spaces)
              * fun(remove_special_chars)
              * fun(lowercase)
              * fun(trim)

local title = '  Hello, World! This is Amazing  '
local slug = slugify % title
print(slug)  -- hello_world_this_is_amazing
```

#### Mathematical Computations

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

## 🚀 Advanced Patterns

### Pipeline-Style (`Arrow`) Advanced Patterns

#### Debugging Pipeline

```lua
local arrow = require('luarrow').arrow

-- Debug wrapper that logs intermediate values
local debug = function(label)
  return function(x)
    print(string.format('[DEBUG %s]: %s', label, tostring(x)))
    return x
  end
end

-- Create a pipeline with debug points (left-to-right flow)
local add_one = function(x) return x + 1 end
local double = function(x) return x * 2 end
local square = function(x) return x * x end

local result = 5
             % arrow(debug('input'))
             ^ arrow(add_one)
             ^ arrow(debug('after add_one'))
             ^ arrow(double)
             ^ arrow(debug('after double'))
             ^ arrow(square)
             ^ arrow(debug('final'))
-- Output:
-- [DEBUG input]: 5
-- [DEBUG after add_one]: 6
-- [DEBUG after double]: 12
-- [DEBUG final]: 144
print('Result:', result)  -- 144
```

#### Composition with Side Effects

```lua
local arrow = require('luarrow').arrow

-- Functions with side effects
local double = function(x) return x * 2 end

local increment_counter = function(counter)
  return function(x)
    counter.value = counter.value + 1
    return x
  end
end

local log_to_file = function(filename)
  return function(x)
    local file = io.open(filename, 'a')
    file:write(tostring(x) .. '\n')
    file:close()
    return x  -- Pass through the value
  end
end

-- Create a counter
local counter = {value = 0}

-- Create a pipeline with side effects (left-to-right flow)
local process = arrow(double)
              ^ arrow(increment_counter(counter))
              ^ arrow(log_to_file('output.log'))

-- Process multiple values
for i = 1, 5 do
  i % process
end

print('Counter:', counter.value)  -- 5
-- output.log contains: 2, 4, 6, 8, 10
```

### Haskell-Style (`Fun`) Advanced Patterns

#### Partial Application with Composition

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

#### Function Factory Pattern

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

#### Monadic-Style Error Handling

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
  if not n then error('Not a number') end
  return n
end

local validate_positive = function(n)
  if n <= 0 then error('Not positive') end
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
local result1 = process % Ok('10')
print(result1.ok, result1.value)  -- true, 20

local result2 = process % Ok('-5')
print(result2.ok, result2.error)  -- false, 'Not positive'

local result3 = process % Ok('abc')
print(result3.ok, result3.error)  -- false, 'Not a number'
```

## 🏷️ Working with LuaCATS

luarrow provides LuaCATS type annotations in its source code.  
However, due to LuaCATS limitations with generic type inference, **type checking will not work automatically**.

If you want type safety with LuaCATS, you must **explicitly annotate** types yourself:

```lua
local fun = require('luarrow').fun

---@type luarrow.Fun<number, string>
local to_string = fun(function(x) return tostring(x) end)

---@type luarrow.Fun<string, boolean>
local is_long = fun(function(s) return #s > 3 end)

---@type luarrow.Fun<number, boolean>
local composed = is_long * to_string

---@type boolean
local result = composed:apply(1234)  -- Returns: true
```

> [!WARNING]
> Unfortunately, due to LuaCATS's limitations, you must provide `---@type` annotations for all intermediate variables.  
> Without explicit `---@type` annotations, LuaCATS will infer types as `unknown` and will not provide type checking benefits.

We look forward to future improvements in LuaCATS `:D`

## ⚡ Performance Considerations

### Benchmark Results

Performance comparison between luarrow and native Lua using 1,000,000 iterations:

#### Functions used

```lua
local add_one = function(x) return x + 1 end
local double = function(x) return x * 2 end
local square = function(x) return x * x end
```

#### Pre-composed functions

```lua
local native_direct = function(x)
  return h(g(f(x)))
end

local fun_composed = fun(h) * fun(g) * fun(f)
local fun_precomposed = function(x)
  return fun_composed % x
end
```

Result:
- Native Lua: `0.078s`
- Fun (pre-composed): `0.197s`

#### On-the-fly composition (inside loop)

```lua
local native_onthefly = function(x)
  local function native_composed(y)
    return h(g(f(y)))
  end
  return native_composed(x)
end

local fun_onthefly = function(x)
  return fun(h) * fun(g) * fun(f) % x
end
```

Result:
- Native Lua (function wrapper): `0.155s`
- Fun (on-the-fly): `1.476s`

> [!TIP]
> - Benchmark script is here: [benchmark.lua](../scripts/benchmark.lua)  
> - To optimizet this, see: [How to optimize performance](#how-to-optimaize-performance)

### How to optimaize performance

Use pre-compose pattern outside loops:

:o: Good

```lua
local fun = require('luarrow').fun

-- Compose once (pre-composed), and reuse.
-- This allocates objects only once.
local f = fun(add_one) * fun(double)
for i = 1, 1000 do
  result = f % i
end
```

:x: BAD

```lua
local fun = require('luarrow').fun

-- Composing inside loop.
-- This allocates new objects each iteration.
-- Too slower.
for i = 1, 1000 do
  local f = fun(add_one) * fun(double)
  result = f % i
end
```

#### Performance-critical paths

Unfortunately, luarrow has some overhead.

If you are in some performance-critical paths, use Native Lua for:

```lua
local function hot_path(x)
  return f(g(h(x)))  -- Direct function calls
end
```

But luarrow is still good selection if you are interested in **code clarity and maintainability**.

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

luarrow brings the elegance of Haskell's function composition to Lua while maintaining excellent performance and type safety.  
Whether you're building data pipelines, processing configurations, or creating complex transformations, luarrow makes your code more expressive and maintainable.

**Happy functional programming!** 🚀
