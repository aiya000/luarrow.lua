# luarrow.lua

**Haskell-style function composition and application for Lua!**

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
- **Type-safe** - Full luaCATS annotations for editor support
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

**Quick reference:**
- `fun(f)` - Wrap a function for composition
- `f * g` - Compose two functions (`f ∘ g`)
- `f % x` - Apply function to value for this API

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

-- NOTE: This style of function definition is called 'point-free style'. In Haskell, this is a common technique
local process_username = fun(add_prefix) * fun(uppercase) * fun(trim)

local username = process_username % "  alice  "
print(username)  -- "USER: ALICE"
```

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

## 🏷️ Type Annotations

luarrow.lua provides full luaCATS type annotations for editor support:

```lua
local fun = require('luarrow').fun

---@type luarrow.Fun<number, number>
local add_one = fun(function(x) return x + 1 end)

---@type luarrow.Fun<number, number>
local times_two = fun(function(x) return x * 2 end)

---@type luarrow.Fun<number, number>
local composed = add_one * times_two

local result = composed % 10  -- Type-checked!
```

## 📖 Documentation

- **[API Reference](doc/api.md)** - Complete API documentation with examples and use cases

## 🤝 Contributing

Contributions are welcome! Please check the issues page for current needs.

## 🙏 Acknowledgments

Inspired by Haskell's elegant function composition and the power of operator overloading in Lua.

## 💭 Philosophy

> "The best code is code that reads like poetry."

luarrow.lua brings functional programming elegance to Lua, making your code more expressive, composable, and maintainable. Whether you're building data pipelines, processing lists, or creating complex transformations, luarrow.lua makes your intent crystal clear.

**Happy composing!** 🎯
