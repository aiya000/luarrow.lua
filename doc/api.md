# luarrow API Reference

Complete API documentation for luarrow - The Haskell-inspired function composition library for Lua.

For practical examples and use cases, see [examples.md](examples.md).

## Table of Contents

1. [API Reference](#-api-reference)
    - [Fun class](#fun-class)
    - [fun(f)](#funf)
    - [f * g (Composition Operator)](#f--g-composition-operator)
    - [Fun:compose(g)](#funcomposeg)
    - [f % x (Application Operator)](#f--x-application-operator)
    - [Fun:apply(x)](#funapplyx)
    - [Pure class](#pure-class)
    - [pure(value)](#purevalue)
    - [pure(f) * pure(g) (Applicative Composition)](#puref--pureg-applicative-composition)
    - [Pure:fmap(mg)](#purefmapmg)
    - [pure(f) % x (Applicative Application)](#puref--x-applicative-application)
    - [Pure:apply(x)](#pureapplyx)

## 📖 API Reference

### `Fun` class

The `luarrow.Fun<A, B>` class represents a wrapped function from type A to type B (`A → B`).

```lua
---@class luarrow.Fun<A, B>
---@field raw fun(x: A): B  -- The original unwrapped function
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

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
- `f: fun(x: A): B` - Lua function

**Returns:**
- `luarrow.Fun<A, B>` - Wrapped function object

### `f * g` (Composition Operator)

Composes two functions using the `*` operator.  
Returns a new function that applies `g` first, then `f`.

```lua
local f = fun(function(x) return x + 1 end)
local g = fun(function(x) return x * 2 end)

local composed = f * g
local result = composed % 5
print(result)  -- 11, because f(g(5)) = f(10) = 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type / Input type
- `C` - Output type

**Parameters:**
- `f: luarrow.Fun<B, C>` - A function that applied second
- `g: luarrow.Fun<A, B>` - A function that applied first

**Returns:**
- `luarrow.Fun<A, C>` - Composed function

- - -

#### Note(1)

The order follows mathematical notation:

- `(f ∘ g)(x) = f(g(x))`

In other words, you can think of:

- `f * g`
    - = `f ∘ g`

as evaluating from right to left:

- `f ← g`

- - -

#### Note(2)

In other terms, this represents the logical syllogism:

- "If B implies C, and A implies B, then A implies C."

In terms of function types, this is:

- `Fun<B, C> → Fun<A, B> → Fun<A, C>`

Or more simply:

-  `(B → C) → (A → B) → (A → C)`

- - -

### `Fun:compose(g)`

Method-style composition.
Equivalent to `f * g` operator.

```lua
local f = fun(function(x) return x + 1 end)
local g = fun(function(x) return x * 2 end)

local composed = f:compose(g)
local result = composed:apply(5)
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type / Input type
- `C` - Output type

**Parameters:**
- `self: luarrow.Fun<B, C>` - A function that applied second
- `g: luarrow.Fun<A, B>` - A function that applied first

**Returns:**
- `luarrow.Fun<A, C>` - Composed function

See [Note(1)](#note1) and [Note(2)](#note2) above for details on composition order and type relationships.

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

Method-style application.  
Equivalent to `f % x` operator.

```lua
local f = fun(function(x) return x + 1 end)

local result = f:apply(10)
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `self: luarrow.Fun<A, B>` - The wrapped function
- `x: A` - Value to apply the function to

**Returns:**
- `B` - Result of applying the function

---

## Applicative-Style Operations

### `Pure` class

The `luarrow.Pure<A>` class represents a value wrapped in an applicative context.  
It enables **applicative-style function application** inspired by Haskell's Applicative functors.

```lua
---@class luarrow.Pure<A>
---@field value A  -- The wrapped value
```

**Type Parameters:**
- `A` - The type of the wrapped value

**Fields:**
- `value: A` - The wrapped value

### `pure(value)`

Wraps a value (including functions) in the Pure applicative context.

```lua
local pure = require('luarrow').pure

-- Wrap a function
local add_one = pure(function(x) return x + 1 end)

-- Wrap a value
local wrapped_value = pure(10)
```

**Type Parameters:**
- `A` - Type of the value to wrap

**Parameters:**
- `value: A` - Value to wrap (can be a function or any other value)

**Returns:**
- `luarrow.Pure<A>` - Wrapped value in applicative context

### `pure(f) * pure(g)` (Applicative Composition)

Composes two wrapped functions using the `*` operator.  
Returns a new wrapped function that applies `g` first, then `f`.

```lua
local pure = require('luarrow').pure

local add_one = function(x) return x + 1 end
local times_two = function(x) return x * 2 end

local composed = pure(add_one) * pure(times_two)
local result = composed % 10
print(result)  -- 21, because add_one(times_two(10)) = add_one(20) = 21
```

**Type Parameters:**
- `A` - Input type
- `B` - Intermediate type
- `C` - Output type

**Parameters:**
- `f: luarrow.Pure<fun(x: B): C>` - A wrapped function that is applied second
- `g: luarrow.Pure<fun(x: A): B>` - A wrapped function that is applied first

**Returns:**
- `luarrow.Pure<fun(x: A): C>` - Composed wrapped function

### `Pure:fmap(mg)`

Method-style composition.  
Equivalent to `pure(f) * pure(g)` operator.

```lua
local pure = require('luarrow').pure

local f = pure(function(x) return x + 1 end)
local g = pure(function(x) return x * 2 end)

local composed = f:fmap(g)
local result = composed:apply(10)
print(result)  -- 21
```

**Type Parameters:**
- `A` - Input type
- `B` - Intermediate type
- `C` - Output type

**Parameters:**
- `self: luarrow.Pure<fun(x: B): C>` - The wrapped function to apply second
- `mg: luarrow.Pure<fun(x: A): B>` - The wrapped function to apply first

**Returns:**
- `luarrow.Pure<fun(x: A): C>` - Composed wrapped function

### `pure(f) % x` (Applicative Application)

Applies a wrapped function to a value using the `%` operator.

```lua
local pure = require('luarrow').pure

local add_one = pure(function(x) return x + 1 end)

local result = add_one % 10
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `f: luarrow.Pure<fun(x: A): B>` - Wrapped function
- `x: A` - Value to apply the function to

**Returns:**
- `B` - Result of applying the function

### `Pure:apply(x)`

Method-style application.  
Equivalent to `pure(f) % x` operator.

```lua
local pure = require('luarrow').pure

local add_one = pure(function(x) return x + 1 end)

local result = add_one:apply(10)
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `self: luarrow.Pure<fun(x: A): B>` - The wrapped function
- `x: A` - Value to apply the function to

**Returns:**
- `B` - Result of applying the function
