# luarrow API Reference

Complete API documentation for luarrow - The Haskell-inspired function composition library for Lua.

For practical examples and use cases, see [examples.md](examples.md).

## Table of Contents

1. [API Reference](#-api-reference)
    - [Fun Class](#fun-class)
    - [fun(f)](#funf)
    - [f * g (Composition Operator)](#f--g-composition-operator)
    - [Fun:compose(g)](#funcomposeg)
    - [f % x (Application Operator)](#f--x-application-operator)
    - [Fun:apply(x)](#funapplyx)

## 📖 API Reference

### `Fun` class

The `luarrow.Fun<A, B>` class represents a wrapped function from type A to type B.

```lua
---@class luarrow.Fun<A, B>
---@field raw fun(x: A): B  -- The original unwrapped function
```

**Type Parameters:**
- `<A, B>` - Generic type parameters where `A` is the input type and `B` is the output type

**Fields:**
- `raw: fun(x: A): B` - The original unwrapped Lua function

### `fun(f)`

Wraps a Lua function into a `Fun` object that supports composition and application.

```lua
local fun = require('luarrow').fun
local wrapped = fun(function(x) return x * 2 end)
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `f: fun(x: A): B` - Any Lua function

**Returns:**
- `luarrow.Fun<A, B>` - Wrapped function object

### `f * g` (Composition Operator)

Composes two functions using the `*` operator. Returns a new function that applies `g` first, then `f`.

```lua
local f = fun(function(x) return x + 1 end)
local g = fun(function(x) return x * 2 end)

local composed = f * g
local result = composed % 5
print(result)  -- 11, because f(g(5)) = f(10) = 11
```

**Type Parameters:**
- `A` - Input type of the second function (applied first)
- `B` - Output type of the second function / Input type of the first function
- `C` - Output type of the first function (applied second)

**Parameters:**
- `f: luarrow.Fun<B, C>` - First function (applied second)
- `g: luarrow.Fun<A, B>` - Second function (applied first)

**Returns:**
- `luarrow.Fun<A, C>` - Composed function

**Note:** The order follows mathematical notation: `(f ∘ g)(x) = f(g(x))`

### `Fun:compose(g)`

Method-style composition. Equivalent to `f * g` operator.

```lua
local f = fun(function(x) return x + 1 end)
local g = fun(function(x) return x * 2 end)

local composed = f:compose(g)
local result = composed:apply(5)
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type of the second function (applied first)
- `B` - Output type of the second function / Input type of the first function
- `C` - Output type of the first function (applied second)

**Parameters:**
- `g: luarrow.Fun<A, B>` - Function to compose with (applied first)

**Returns:**
- `luarrow.Fun<A, C>` - Composed function

### `f % x` (Application Operator)

Applies the wrapped function to a value using the `%` operator.

```lua
local f = fun(function(x) return x + 1 end)

local result = f % 10
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `f: luarrow.Fun<A, B>` - Wrapped function
- `x: A` - Value to apply the function to

**Returns:**
- `B` - Result of applying the function

### `Fun:apply(x)`

Method-style application. Equivalent to `f % x` operator.

```lua
local f = fun(function(x) return x + 1 end)

local result = f:apply(10)
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `x: A` - Value to apply the function to

**Returns:**
- `B` - Result of applying the function
