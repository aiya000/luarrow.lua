# luarrow

**Haskell-style function composition and true pipeline operators for Lua!**

Bring the elegance of Haskell's `f . g $ x` syntax to Lua with beautiful operator overloading.

```lua
local fun = require('luarrow').fun

local function f(x) return x + 1 end
local function g(x) return x * 10 end
local function h(x) return x - 2 end

-- Compose and apply with Haskell-like syntax!
local result = fun(f) * fun(g) * fun(h) % 42
print(result)  -- 401
```

Equivalent to:

```haskell
-- Haskell
f . g . h $ 42
```

## ✨ Why luarrow?

Functional programming in Lua just got **dramatically** more expressive:

- **Haskell-inspired syntax** - Write `f * g % x` instead of `f(g(x))`
- **Zero dependencies** - Pure Lua implementation with no external dependencies
- **Minimal overhead** - Lightweight wrapper around native Lua functions
- **Elegant composition** - Chain multiple functions naturally with `*` operator
- **Beautiful code** - Make your functional pipelines readable and maintainable

**About the name:** "luarrow" is a portmanteau of "Lua" + "arrow", where "arrow" refers to the function arrow (→) commonly used in mathematics and functional programming to denote functions (`A → B`).

## 🚀 Quick Start

### Basic Function Composition

Elegant Example:

```lua
local fun = require('luarrow').fun

local function f(x) return x + 1 end
local function g(x) return x * 10 end
local function h(x) return x - 2 end

local result = fun(f) * fun(g) * fun(h) % 42
print(result)  -- 401
```

Step-by-step Explanation:

```lua
local fun = require('luarrow').fun

local plus_one = function(x) return x + 1 end
local times_two = function(x) return x * 2 end

-- Compose functions with * operator
local composed = fun(plus_one) * fun(times_two)

-- Apply with % operator
local result = composed % 10

print(result)  -- 21
-- because plus_one(times_two(10)) = plus_one(20) = 21
```

### Method-Style API

If you prefer explicit method calls, they're available too:

```lua
local k = fun(f):compose(fun(g))
local result = k:apply(10)
print(result)  -- 21
```

This is equivalent to:

```lua
local k = fun(f) * fun(g)
local result = k % 10
print(result)  -- 21
```

### Chaining Multiple Functions

```lua
local add_one = function(x) return x + 1 end
local times_ten = function(x) return x * 10 end
local minus_two = function(x) return x - 2 end

-- Chain as many functions as you want!
local result = fun(add_one) * fun(times_ten) * fun(minus_two) % 42
print(result)  -- 401
-- Evaluation: minus_two(42) = 40
--             times_ten(40) = 400
--             add_one(400) = 401
```

### Applicative-Style Function Application

The Identity monad (available as `identity` or `pure` for backward compatibility) provides applicative-style function composition:

```lua
local identity = require('luarrow').identity

local function f(x) return x + 1 end
local function g(x) return x * 10 end
local function h(x) return x - 2 end

-- Applicative style composition and application
local result = identity(f) * identity(g) * identity(h) % 42
print(result)  -- 401
```

luarrow also provides **Maybe** and **Either** monads for handling optional values and errors:

```lua
local just = require('luarrow').just
local nothing = require('luarrow').nothing

-- Maybe monad for optional values
local safe_divide = function(x)
  return function(y)
    if y == 0 then return nothing() else return just(x / y) end
  end
end

local result = just(10) % safe_divide(5)  -- just(2.0)
print(result:or_else(0))  -- 2.0
```

## 📦 Installation

### With luarocks

```shell-session
$ luarocks install luarrow
```

Check that it is installed correctly:

```shell-session
$ eval $(luarocks path) && lua -e "local l = require('luarrow'); print('Installed correctly!')"
```

### With Git

```shell-session
$ git clone https://github.com/aiya000/luarrow.lua
$ cd luarrow.lua
$ make install-to-local
```

## 📚 API Reference

For complete API documentation, see **[doc/api.md](doc/api.md)**.

For practical examples and use cases, see **[doc/examples.md](doc/examples.md)**.

**Quick reference:**
- `fun(f)` - Wrap a function for composition
- `f * g` - Compose two functions (`f ∘ g`)
- `f % x` - Apply function to value for this API
- **Monads:**
  - `identity(value)` / `pure(value)` - Identity monad
  - `just(value)`, `nothing()` - Maybe monad for optional values
  - `right(value)`, `left(error)` - Either monad for error handling

## 🔄 Comparison with Haskell

| Haskell | luarrow.lua | Pure Lua |
|---------|-------------|----------|
| `let k = f . g` | `local k = fun(f) * fun(g)` | `local function k(x) return f(g(x)) end` |
| `f . g . h $ x` | `fun(f) * fun(g) * fun(h) % x` | `f(g(h(x)))` |

The syntax is remarkably close to Haskell's elegance, while staying within Lua's operator overloading capabilities!

## 💡 Real-World Examples

### Data Transformation Pipeline

```lua
local fun = require('luarrow').fun

local trim = function(s) return s:match("^%s*(.-)%s*$") end
local uppercase = function(s) return s:upper() end
local add_prefix = function(s) return "USER: " .. s end

local process_username = fun(add_prefix) * fun(uppercase) * fun(trim)

local username = process_username % "  alice  "
print(username)  -- "USER: ALICE"
```

**Important Note**:  
This definition style for `process_username` is what Haskell programmers call '**Point-Free Style**'!  
In Haskell, this is a very common technique to reduce the amount of code and improve readability.

### Numerical Computations

```lua
local fun = require('luarrow').fun

local square = function(x) return x * x end
local negate = function(x) return -x end
local add_ten = function(x) return x + 10 end

local result = fun(negate) * fun(add_ten) * fun(square) % 5
print(result)  -- -35, because square(5)=25, add_ten(25)=35, negate(35)=-35
```

### List Processing

```lua
local fun = require('luarrow').fun

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

local numbers = {1, 2, 3, 4, 5, 6}

local is_even = function(x) return x % 2 == 0 end
local double = function(x) return x * 2 end

local result = fun(map(double)) * fun(filter(is_even)) % numbers
-- result: {4, 8, 12}
```

## 📖 Documentation

- **[API Reference](doc/api.md)** - Complete API documentation
- **[Examples](doc/examples.md)** - Practical examples and use cases

## 🙏 Acknowledgments

Inspired by Haskell's elegant function composition and the power of operator overloading in Lua.

## 💭 Philosophy

> "The best code is code that reads like poetry."

luarrow brings functional programming elegance to Lua, making your code more expressive, composable, and maintainable.
Whether you're building data pipelines, processing lists, or creating complex transformations, luarrow makes your intent crystal clear.

**Happy composing!** 🎯
