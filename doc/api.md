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
    - [Monads](#monads)
        - [Identity Monad](#identity-monad)
        - [Maybe Monad](#maybe-monad)
        - [Either Monad](#either-monad)
    - [identity(value)](#identityvalue)
    - [just(value) and nothing()](#justvalue-and-nothing)
    - [right(value) and left(error)](#rightvalue-and-lefterror)

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

## Monads

luarrow provides three monads for working with computational contexts:

### Identity Monad

The Identity monad is the simplest monad - it wraps a value with no additional structure. It's useful for applicative-style function composition.

```lua
local identity = require('luarrow').identity

local f = function(x) return x + 1 end
local g = function(x) return x * 10 end

-- Compose and apply functions
local result = identity(f) * identity(g) % 5
print(result)  -- 51, because f(g(5)) = f(50) = 51
```

**Note:** `pure` is an alias for `identity` for backward compatibility.

### Maybe Monad

The Maybe monad represents optional values. A Maybe value is either `just(value)` (contains a value) or `nothing()` (empty).

```lua
local just = require('luarrow').just
local nothing = require('luarrow').nothing

-- Safe division
local safe_divide = function(x)
  return function(y)
    if y == 0 then
      return nothing()
    else
      return just(x / y)
    end
  end
end

-- Chain operations with bind (%)
local result1 = just(10) % safe_divide(5)  -- just(2.0)
local result2 = just(10) % safe_divide(0)  -- nothing()

-- Get value with default
print(result1:or_else(0))  -- 2.0
print(result2:or_else(0))  -- 0
```

**Key Methods:**
- `just(value)` - Create a Maybe with a value
- `nothing()` - Create an empty Maybe
- `:fmap(f)` - Map a function over the value (via `*` operator)
- `:bind(f)` - Chain monadic operations (via `%` operator)
- `:or_else(default)` - Get value or default
- `:is_nothing()` - Check if empty

### Either Monad

The Either monad represents computations that may fail with an error. An Either is either `right(value)` (success) or `left(error)` (failure).

```lua
local right = require('luarrow').right
local left = require('luarrow').left

-- Parse a number
local parse_number = function(str)
  local n = tonumber(str)
  if n then
    return right(n)
  else
    return left("Not a number: " .. str)
  end
end

-- Validate positive
local validate_positive = function(n)
  if n > 0 then
    return right(n)
  else
    return left("Not positive: " .. tostring(n))
  end
end

-- Chain operations
local result1 = parse_number("10") % validate_positive  -- right(10)
local result2 = parse_number("abc") % validate_positive  -- left("Not a number: abc")
local result3 = parse_number("-5") % validate_positive   -- left("Not positive: -5")

-- Get value with default
print(result1:or_else(0))  -- 10
print(result2:or_else(0))  -- 0
```

**Key Methods:**
- `right(value)` - Create a successful Either
- `left(error)` - Create a failed Either
- `:fmap(f)` - Map a function over the success value (via `*` operator)
- `:bind(f)` - Chain monadic operations (via `%` operator)
- `:or_else(default)` - Get value or default
- `:is_left()` - Check if contains an error
- `:map_left(f)` - Map a function over the error value

---

### `identity(value)`

Wraps a value in the Identity monad. Alias: `pure(value)` for backward compatibility.

**Parameters:**
- `value: A` - Value to wrap

**Returns:**
- `luarrow.Identity<A>` - Wrapped value

### `just(value)` and `nothing()`

Create Maybe monad values.

**`just(value)`:**
- `value: A` - Value to wrap
- Returns: `luarrow.Maybe<A>` - A Maybe containing the value

**`nothing()`:**
- Returns: `luarrow.Maybe<A>` - An empty Maybe

### `right(value)` and `left(error)`

Create Either monad values.

**`right(value)`:**
- `value: A` - Success value to wrap
- Returns: `luarrow.Either<E, A>` - A successful Either

**`left(error)`:**
- `error: E` - Error value to wrap
- Returns: `luarrow.Either<E, A>` - A failed Either
