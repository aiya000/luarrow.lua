# luarrow API Reference

For practical examples and use cases, see [examples.md](examples.md).

## Table of Contents

1. [Fun API Reference](#-fun-api-reference)
    - [Fun class](#fun-class)
    - [fun(f)](#funf)
    - [f * g (Haskell-Style Composition Operator)](#f--g-haskell-style-composition-operator)
    - [Fun:compose(g)](#funcomposeg)
    - [f % x (Haskell-Style Application Operator)](#f--x-haskell-style-application-operator)
    - [Fun:apply(x)](#funapplyx)
2. [Arrow API Reference](#-arrow-api-reference)
    - [Arrow class](#arrow-class)
    - [arrow(f)](#arrowf)
    - [f ^ g (Pipeline-Style Composition Operator)](#f--g-pipeline-style-composition-operator)
    - [Arrow:compose_to(g)](#arrowcompose_tog)
    - [x % f (Pipeline-Style Application Operator)](#x--f-pipeline-style-application-operator)
    - [Arrow:apply(x)](#arrowapplyx)
3. [Utility Functions API Reference](#-utility-functions-api-reference)
    - [partial(f, arity)](#partialf-arity)
    - [curry(f) / curry2(f)](#curryf--curry2f)
    - [curry3(f), curry4(f), ..., curry8(f)](#curry3f-curry4f--curry8f)
    - [swap(f)](#swapf)

## ⛲ `Fun` API Reference

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

### `f * g` (Haskell-Style Composition Operator)

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

<a name="haskell-style-composition-operator-tips"></a>

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

See [Tips](#haskell-style-composition-operator-tips) above for details on composition order and type relationships.

### `f % x` (Haskell-Style Application Operator)

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

The `luarrow.Arrow<A, B>` class represents a wrapped function from type A to type B (`A → B`).

This is similar to `Fun`, but with **Pipeline-Style** that reads left-to-right.  
(Like the `|>` operator in PHP, Elm, F#, OCaml, Elixir, and etc.)

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
- `Fun`: Composes right-to-left (`←`)
    - `fun(f) * fun(g) % x` means `f(g(x))`
- `Arrow`: Composes left-to-right (`→`)
    - `x % arrow(f) ^ arrow(g)` means `g(f(x))`

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

### `f ^ g` (Pipeline-Style Composition Operator)

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

<a name="pipeline-style-composition-operator-tips"></a>

> [!TIP]
> The order follows **Pipeline-Style** composition (opposite of mathematical notation):
>
> ```lua
> -- Arrow pipeline style (left-to-right)
> x % arrow(f) ^ arrow(g) ^ arrow(h)
>
> -- Equivalent to:
> h(g(f(x)))
> ```
>
> This is similar to:
> - Pipeline Operator in PHP, Elm, F#, OCaml, Elixir, and etc: `x |> f |> g |> h`
> - Haskell's Operator: `x & f >>> g >>> h`
> - Unix pipes: `x | f | g | h`
>
> In other words, you can think of:
> - `f ^ g`
>     - = `f >>> g` (Haskell)
>     - = `f |> g` (Pipeline Operator)
>     - = `f | g` (Unix pipes, conceptually)
>
> as evaluating from left to right:
> - `f → g`

> [!TIP]
> In terms of function types:
> - `Arrow<A, B> → Arrow<B, C> → Arrow<A, C>`
>
> Or more simply:
> - `(A → B) → (B → C) → (A → C)`
>
> This represents the natural data flow from A to B to C.
> (A simpler logical syllogism than `Fun`.)

- - -

### `Arrow:compose_to(g)`

Method-style pipeline composition.
Equivalent to `f ^ g` operator.

```lua
local f = arrow(function(x) return x + 1 end)
local g = arrow(function(x) return x * 2 end)

local composed = f:compose_to(g)
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

See [Tips](#pipeline-style-composition-operator-tips) above for details on composition order and type relationships.

### `x % f` (Pipeline-Style Composition Operator)

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

> [!IMPORTANT]
> This uses the same `%` operator as `Fun`, but the order is reversed:
> - `Fun`: `fun(f) % x` means `f(x)`
> - `Arrow`: `x % arrow(f)` means `f(x)`

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

## 🛠️ Utility Functions API Reference

The `luarrow.utils` module provides utility functions for functional programming patterns like currying and partial application.

**Key Point:** These utilities are **completely standalone** and do not depend on `arrow` or `fun`. While they integrate seamlessly with `arrow` and `fun` pipelines, you can use `curry` and `partial` on their own for general-purpose functional programming in Lua.

```lua
local utils = require('luarrow.utils')

-- Standalone usage (no arrow/fun needed)
local curry = utils.curry
local add_curried = curry(function(a, b) return a + b end)
print(add_curried(10)(5))  -- 15

-- Also works great with arrow/fun
local arrow = require('luarrow').arrow
local result = 42 % arrow(add_curried(10))  -- 52
```

### `partial(f, arity)`

Creates a partially applicable version of a function, enabling seamless integration of multi-argument functions with `arrow` and `fun` pipelines.

This allows you to write `x % arrow(partial(f)(y))` instead of `x % arrow(function(x) return f(x, y) end)`, making it much more concise and expressive when integrating functions that take multiple arguments.

```lua
local arrow = require('luarrow').arrow
local partial = require('luarrow.utils').partial

local function add(a, b, c)
  return a + b + c
end

-- Partial application styles
add_partial = partial(add)

-- All of these work:
add_partial(1)(2)(3)        -- 6
add_partial(1, 2)(3)        -- 6
add_partial(1)(2, 3)        -- 6
add_partial(1, 2, 3)        -- 6

-- Integration with arrow/fun:
local result = 42
  % arrow(partial(add)(10, 20))  -- 72 (= (10 + 20) + 42)
  ^ arrow(partial(multiply)(100)) -- 7200 (= 72 * 100)
```

**Type Parameters:**
- `...` - Variable argument types

**Parameters:**
- `f: function` - The function to make partially applicable
- `arity: number | nil` - Optional: Number of parameters the function expects (auto-detected if omitted)

**Returns:**
- `function` - A partially applicable version of the function

**Advanced Usage:**

You can also combine `partial()` with multiple arguments in pipelines:

```lua
-- Multi-argument functions in pipelines
local function format(prefix, suffix, text)
  return prefix .. text .. suffix
end

local result = "hello"
  % arrow(partial(format)("[", "]"))  -- "[hello]"
  ^ arrow(string.upper)               -- "[HELLO]"
```

**When combined with `swap()`:**

```lua
local function divide(a, b)
  return a / b
end

-- Swap arguments and partially apply
local result = 100
  % arrow(partial(swap(divide))(2))  -- 50 (= 100 / 2)
```

**Important Notes:**

> [!IMPORTANT]
> This function may not work correctly with:
> 1. **C functions** (Lua built-in functions or functions written in C)
> 2. **JIT-compiled functions** (in LuaJIT, debug information may be lost)
> 3. **Variadic-only functions** (functions with only `...` parameters)
>
> For these cases, you have two options:
> - Explicitly specify the `arity` parameter: `partial(f, 2)`
> - Use `curry()` or `curry[3-8]()` functions instead (see below)

**Examples of when you need to specify arity or use curry:**

```lua
-- C function - won't work without arity
local p = partial(string.sub, 3)  -- Explicitly specify arity=3

-- Or use curry for a fixed number of arguments:
local curry3 = require('luarrow.utils').curry3
local substring = curry3(string.sub)
```

### `curry(f)` / `curry2(f)`

Converts a two-argument function into a curried form.

This is the traditional currying function from programming history, converting `(A, B) → C` into `A → (B → C)`.

**Unlike `partial()`**, `curry()` functions work reliably with C functions, JIT-compiled functions, and other edge cases because they don't rely on debug information.

```lua
local curry = require('luarrow.utils').curry
local arrow = require('luarrow').arrow

local function add(a, b)
  return a + b
end

local add_curried = curry(add)

-- Curried application
add_curried(10)(5)  -- 15

-- Integration with arrow/fun
local result = 42
  % arrow(add_curried(10))  -- 52
```

**Type Parameters:**
- `A` - First argument type
- `B` - Second argument type
- `C` - Return type

**Parameters:**
- `f: fun(a: A, b: B): C` - Two-argument function

**Returns:**
- `fun(a: A): fun(b: B): C` - Curried function

**Comparison with `partial()`:**

```lua
-- partial: More flexible, but may fail with C functions
local p = partial(add)
p(1, 2)     -- ✓ Works
p(1)(2)     -- ✓ Works

-- curry: More reliable, but strict single-argument application
local c = curry(add)
c(1, 2)     -- ✗ Doesn't work (only returns intermediate function)
c(1)(2)     -- ✓ Works

-- However, curry is MORE RELIABLE with C functions:
local sub_p = partial(string.sub, 3)  -- ✓ Need explicit arity
local sub_c = curry3(string.sub)      -- ✓ Always works, no arity needed
```

Use `curry()` when:
- You need guaranteed compatibility with C functions
- You prefer the traditional currying style
- You're working with exactly 2 arguments

Use `partial()` when:
- You want flexible argument application (one-by-one OR multiple at once)
- You're working with Lua functions (not C functions)
- You want more flexibility in how arguments are provided

### `curry3(f)`, `curry4(f)`, ..., `curry8(f)`

Similar to `curry()`, but for functions with 3 to 8 arguments.

These functions provide reliable currying for multi-argument functions, especially useful as an alternative when `partial()` encounters issues with C functions, JIT-compiled functions, or variadic functions.

```lua
local curry3 = require('luarrow.utils').curry3
local arrow = require('luarrow').arrow

local function add3(a, b, c)
  return a + b + c
end

local add3_curried = curry3(add3)

-- Curried application (one argument at a time)
add3_curried(10)(20)(30)  -- 60

-- Integration with arrow
local result = 42
  % arrow(add3_curried(10)(20))  -- 72 (= 10 + 20 + 42)
```

**Available functions:**
- `curry3(f)` - For 3-argument functions: `(A, B, C) → D` becomes `A → B → C → D`
- `curry4(f)` - For 4-argument functions: `(A, B, C, D) → E` becomes `A → B → C → D → E`
- `curry5(f)` - For 5-argument functions
- `curry6(f)` - For 6-argument functions
- `curry7(f)` - For 7-argument functions
- `curry8(f)` - For 8-argument functions

**Why these exist:**

These functions solve the limitations of `partial()`:

```lua
local partial = require('luarrow.utils').partial
local curry3 = require('luarrow.utils').curry3

-- partial() doesn't work with C functions without explicit arity
local sub1 = partial(string.sub)  -- ✗ Error: Cannot determine arity
local sub2 = partial(string.sub, 3)  -- ✓ Works with explicit arity

-- curry3() works reliably without needing arity specification
local sub3 = curry3(string.sub)  -- ✓ Always works
local result = "hello" % arrow(sub3(1)(3))  -- "hel"
```

**Type Signatures:**

```lua
-- curry3
---@generic A, B, C, D
---@param f fun(a: A, b: B, c: C): D
---@return fun(a: A): fun(b: B): fun(c: C): D

-- curry4
---@generic A, B, C, D, E
---@param f fun(a: A, b: B, c: C, d: D): E
---@return fun(a: A): fun(b: B): fun(c: C): fun(d: D): E

-- (And so on for curry5-8...)
```

**Practical Example:**

```lua
local curry3 = require('luarrow.utils').curry3
local arrow = require('luarrow').arrow

-- Using string.sub (a C function) with curry3
local substring = curry3(string.sub)

"Hello, World!"
  % arrow(substring(1)(5))  -- "Hello"
  ^ arrow(string.upper)     -- "HELLO"
  ^ arrow(print)            -- Prints: HELLO
```

> [!TIP]
> While providing up to `curry8` might seem like overkill, it ensures comprehensive support for various multi-argument scenarios. In practice, most use cases will only need `curry`, `curry3`, or `curry4`.

### `swap(f)`

Swaps the first two arguments of a two-argument function.

This is useful for argument order adjustment when integrating functions into pipelines.

```lua
local swap = require('luarrow.utils').swap
local arrow = require('luarrow').arrow
local partial = require('luarrow.utils').partial

local function divide(a, b)
  return a / b
end

local divide_swapped = swap(divide)

divide(10, 2)          -- 5 (= 10 / 2)
divide_swapped(10, 2)  -- 0.2 (= 2 / 10)

-- Integration with arrow/partial
local result = 100
  % arrow(partial(swap(divide))(2))  -- 50 (= 100 / 2)
```

**Type Parameters:**
- `A` - First argument type
- `B` - Second argument type
- `C` - Return type

**Parameters:**
- `f: fun(a: A, b: B): C` - Two-argument function

**Returns:**
- `fun(b: B, a: A): C` - Function with swapped argument order

**Practical Example:**

```lua
local arrow = require('luarrow').arrow
local partial = require('luarrow.utils').partial
local swap = require('luarrow.utils').swap

-- Without swap: awkward argument order
local function power(base, exponent)
  return base ^ exponent
end

-- We want to square numbers in a pipeline
local result1 = 5
  % arrow(partial(power)(nil, 2))  -- Doesn't work as intended

-- With swap: natural argument order
local result2 = 5
  % arrow(partial(swap(power))(2))  -- 25 (= 5^2)

-- Pipeline processing multiple values
local numbers = {2, 3, 4, 5}
local square = arrow(partial(swap(power))(2))

for _, n in ipairs(numbers) do
  print(n % square)  -- 4, 9, 16, 25
end
```
