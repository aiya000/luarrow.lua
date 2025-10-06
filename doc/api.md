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
2. [Arrow API Reference](#-arrow-api-reference)
    - [Arrow class](#arrow-class)
    - [arrow(f)](#arrowf)
    - [f ^ g (Pipeline Composition Operator)](#f--g-pipeline-composition-operator)
    - [Arrow:to(g)](#arrowtog)
    - [x % f (Pipeline Application Operator)](#x--f-pipeline-application-operator)
    - [Arrow:apply(x)](#arrowapplyx)

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

> [!TIP]
> The order follows mathematical notation:
>
> - `(f ∘ g)(x) = f(g(x))`
>
> In other words, you can think of:
>
> - `f * g` - (luarrow)
> - `f ∘ g` - (Math)
>
> as evaluating from right to left:
>
> - `f ← g`

> [!TIP]
> In other terms, this represents the logical syllogism:
>
> - "If B implies C, and A implies B, then A implies C."
>
> In terms of function types, this is:
>
> - `Fun<B, C> → Fun<A, B> → Fun<A, C>`
>
> Or more simply:
>
> -  `(B → C) → (A → B) → (A → C)`
>
> If we change the order of the functions in the arguments,
> it may help you to easier understand,  
> although this is different from the actual arguments.
>
> - `Fun<A, B> → Fun<B, C> → Fun<A, C>`
> - `(A → B) → (B → C) → (A → C)`

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

## 🎯 Arrow API Reference

### `Arrow` class

The `luarrow.Arrow<A, B>` class represents a wrapped function from type A to type B (`A → B`), similar to `Fun` but with **pipeline-style composition** that reads left-to-right (like the `|>` operator in Elm, F#, OCaml, Elixir).

```lua
---@class luarrow.Arrow<A, B>
---@field raw fun(x: A): B  -- The original unwrapped function
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Fields:**
- `raw: fun(x: A): B` - The original unwrapped Lua function

**Key Difference from `Fun`:**
- `Fun`: Composes right-to-left (mathematical style) - `fun(f) * fun(g) % x` means `f(g(x))`
- `Arrow`: Composes left-to-right (pipeline style) - `x % arrow(f) ^ arrow(g)` means `g(f(x))`

### `arrow(f)`

Wraps a Lua function into an `Arrow` object that supports pipeline-style composition and application.

```lua
local arrow = require('luarrow').arrow
local wrapped = arrow(function(x) return x * 2 end)
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `f: fun(x: A): B` - Lua function

**Returns:**
- `luarrow.Arrow<A, B>` - Wrapped function object

### `f ^ g` (Pipeline Composition Operator)

Composes two functions using the `^` operator in **pipeline order** (left-to-right).  
Returns a new function that applies `f` first, then `g`.

```lua
local f = arrow(function(x) return x + 1 end)
local g = arrow(function(x) return x * 2 end)

local composed = f ^ g
local result = 5 % composed
print(result)  -- 12, because g(f(5)) = g(6) = 12
```

**Type Parameters:**
- `A` - Input type
- `B` - Intermediate type
- `C` - Output type

**Parameters:**
- `f: luarrow.Arrow<A, B>` - A function that is applied first
- `g: luarrow.Arrow<B, C>` - A function that is applied second

**Returns:**
- `luarrow.Arrow<A, C>` - Composed function

- - -

#### Note(1)

The order follows **pipeline/Unix-style** composition (opposite of mathematical notation):

```lua
-- Arrow pipeline style (left-to-right)
x % arrow(f) ^ arrow(g) ^ arrow(h)
-- Equivalent to:
h(g(f(x)))
```

This is similar to:
- Unix pipes: `x | f | g | h`
- Haskell's `>>>` operator: `f >>> g >>> h`
- Pipeline Operator `|>` in Elm, F#, OCaml, Elixir: `x |> f |> g |> h`
- Pipeline Operator in other languages (Rust, Hack, etc.)

In other words, you can think of:
- `f ^ g`
    - = `f >>> g` (Haskell)
    - = `f |> g` (Pipeline Operator)
    - = `f | g` (Unix pipes, conceptually)

as evaluating from left to right:
- `f → g`

- - -

#### Note(2)

In terms of function types:
- `Arrow<A, B> → Arrow<B, C> → Arrow<A, C>`

Or more simply:
- `(A → B) → (B → C) → (A → C)`

This represents the natural data flow from A to B to C.

- - -

### `Arrow:to(g)`

Method-style pipeline composition.
Equivalent to `f ^ g` operator.

```lua
local f = arrow(function(x) return x + 1 end)
local g = arrow(function(x) return x * 2 end)

local composed = f:to(g)
local result = composed:apply(5)
print(result)  -- 12
```

**Type Parameters:**
- `A` - Input type
- `B` - Intermediate type
- `C` - Output type

**Parameters:**
- `self: luarrow.Arrow<A, B>` - A function that is applied first
- `g: luarrow.Arrow<B, C>` - A function that is applied second

**Returns:**
- `luarrow.Arrow<A, C>` - Composed function

See [Note(1)](#note1-1) and [Note(2)](#note2-1) above for details on composition order and type relationships.

### `x % f` (Pipeline Application Operator)

Applies the wrapped function to a value using the `%` operator in **pipeline style**.

```lua
local f = arrow(function(x) return x + 1 end)

local result = 10 % f
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `x: A` - Value to apply the function to
- `f: luarrow.Arrow<A, B>` - Wrapped function

**Returns:**
- `B` - Result of applying the function

**Note:** This uses the same `%` operator as `Fun`, but the order is reversed:
- `Fun`: `fun(f) % x` means `f(x)`
- `Arrow`: `x % arrow(f)` means `f(x)`

### `Arrow:apply(x)`

Method-style application.  
Equivalent to `x % f` operator.

```lua
local f = arrow(function(x) return x + 1 end)

local result = f:apply(10)
print(result)  -- 11
```

**Type Parameters:**
- `A` - Input type
- `B` - Output type

**Parameters:**
- `self: luarrow.Arrow<A, B>` - The wrapped function
- `x: A` - Value to apply the function to

**Returns:**
- `B` - Result of applying the function
