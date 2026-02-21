# luarrow API Reference

For practical examples and use cases, see [examples.md](examples.md).

## Table of Contents

1. [Fun API Reference](#fun-api-reference)
    - [Fun class](#fun-class)
    - [fun(f)](#funf)
    - [f * g (Haskell-Style Composition Operator)](#f-g-haskell-style-composition-operator)
    - [Fun:compose(g)](#funcomposeg)
    - [f % x (Haskell-Style Application Operator)](#f-x-haskell-style-application-operator)
    - [Fun:apply(x)](#funapplyx)
2. [Arrow API Reference](#arrow-api-reference)
    - [Arrow class](#arrow-class)
    - [arrow(f)](#arrowf)
    - [f ^ g (Pipeline-Style Composition Operator)](#f-g-pipeline-style-composition-operator)
    - [Arrow:compose_to(g)](#arrowcompose_tog)
    - [x % f (Pipeline-Style Application Operator)](#x-f-pipeline-style-application-operator)
    - [Arrow:apply(x)](#arrowapplyx)
3. [Let API Reference](#let-api-reference)
    - [Let class](#let-class)
    - [let(...)](#let)
    - [let(...) % arrow\_or\_fun (Multi-Value Pipeline Entry)](#let--arrow_or_fun-multi-value-pipeline-entry)
4. [luarrow.utils.list API Reference](#-luarrowutilslist-api-reference)
    - [Basic Operations](#basic-operations)
    - [Fold Operations](#fold-operations)
    - [Aggregation](#aggregation)
    - [Inspection](#inspection)
    - [Transformation](#transformation)
    - [Search](#search)

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

> [!NOTE]
> Due to LuaCATS limitations, `Fun<A, B>` is only typed with a single input type `A` and a single output type `B`.  
> For details on both multiple arguments and multiple return values, see [Type Limitations in `Fun:apply()`](#fun-apply-type-limitations).

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

> [!NOTE]
> Due to LuaCATS limitations, `fun(f)` is typed with fixed parameters `A` and `B`.  
> For details on both multiple arguments and multiple return values, see [Type Limitations in `Fun:apply()`](#fun-apply-type-limitations).

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

**Multiple Values in Composition:**

Functions in a composition chain can accept and return multiple values, which are properly propagated through the chain:

```lua
-- Function returning multiple values
local split = fun(function(x)
  return x, x * 2
end)

-- Function accepting multiple values
local add = fun(function(a, b)
  return a + b
end)

local composed = add * split
local result = composed:apply(5)  -- Returns 15 (5 + 10)
```

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

#### Multiple Arguments and Return Values

The `apply()` method supports multiple arguments and return values:

```lua
---@type fun(x: integer): integer, integer
local split = fun(function(x)
  return x, x * 2
end)

---@type fun(x: integer, y: integer): integer
local add = fun(function(x, y)
  return x + y
end)

local result = fun(add) * fun(split) % 10
-- 30
```

<a name="fun-apply-type-limitations"></a>

> [!NOTE]
> Due to LuaCATS limitations, `fun()` does not support variadic type parameters.  
> It is typed with fixed type parameters `A` and `B`, representing a single input and a single output.

<a name="fun-muitiple-arguments-and-multiple-return-values"></a>

> [!NOTE]
> When using the `%` operator (`f % x`), only single values are supported due to Lua's metamethod limitations.  
> If you want to capture multiple return values using the `%` operator, prepend `fun(table.pack)` at the front of the composition chain to collect all values into a table:
>
> ```lua
> local result1, result2 = fun(split) % 10
> -- result1: 10
> -- result2: nil
>
> local result = fun(table.pack) * fun(split) % 10
> -- result[1]: 10
> -- result[2]: 20
> ```
>
> Or use the `apply()` method for multiple arguments or when you need to capture multiple return values.
> ```lua
> local result1, result2 = fun(split):apply(10)
> -- result1: 10
> -- result2: 20
> ```

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

> [!NOTE]
> Due to LuaCATS limitations, `Arrow<A, B>` is only typed with a single input type `A` and a single output type `B`.  
> For details on both multiple arguments and multiple return values, see [Type Limitations in `Arrow:apply()`](#arrow-apply-type-limitations).

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

> [!NOTE]
> Due to LuaCATS limitations, `arrow(f)` is typed with fixed parameters `A` and `B`.  
> For details on both multiple arguments and multiple return values, see [Type Limitations in `Arrow:apply()`](#arrow-apply-type-limitations).

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

**Multiple Values in Composition:**

Functions in a composition chain can accept and return multiple values, which are properly propagated through the chain:

```lua
-- Function returning multiple values
local split = arrow(function(x)
  return x, x * 2
end)

-- Function accepting multiple values
local add = arrow(function(a, b)
  return a + b
end)

local composed = split ^ add
local result = composed:apply(5)  -- Returns 15 (5 + 10)
```

See [Tips](#pipeline-style-composition-operator-tips) above for details on composition order and type relationships.

### `x % f` (Pipeline-Style Application Operator)

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

#### Multiple Arguments and Return Values

The `apply()` method supports multiple arguments and return values:

```lua
---@type fun(x: integer): integer, integer
local split = arrow(function(x)
  return x, x * 2
end)

---@type fun(x: integer, y: integer): integer
local add = arrow(function(x, y)
  return x + y
end)

local result = 10 % arrow(split) ^ arrow(add)
-- 30
```

<a name="arrow-apply-type-limitations"></a>

> [!NOTE]
> Due to LuaCATS limitations, `arrow()` does not support variadic type parameters.  
> It is typed with fixed type parameters `A` and `B`, representing a single input and a single output.

<a name="arrow-muitiple-arguments-and-multiple-return-values"></a>

> [!NOTE]
> When using the `%` operator (`x % f`), only single values are supported due to Lua's metamethod limitations.
> If you want to capture multiple return values using the `%` operator, append `arrow(table.pack)` at the end of the composition chain to collect all values into a table:
>
> ```lua
> local result1, result2 = 10 % arrow(split)
> -- result1: 10
> -- result2: nil
>
> local result = 10 % arrow(split) ^ arrow(table.pack)
> -- result[1]: 10
> -- result[2]: 20
> ```
>
> Or use the `apply()` method for multiple arguments or when you need to capture multiple return values.
> ```lua
> local result1, result2 = arrow(split):apply(10)
> -- result1: 10
> -- result2: 20
> ```

## 🔖 `Let` API Reference

### `Let` class

The `luarrow.Let` class holds multiple values as a bundle, to be used as the entry point of a pipeline without needing `:apply()`.

```lua
---@class luarrow.Let
---@field _values unknown[]  -- The stored values
```

> [!TIP]
> `Let` is the recommended way to start a pipeline that takes multiple initial values.
> It works with both `arrow` (pipeline-style) and `fun` (Haskell-style):
>
> ```lua
> -- Arrow style
> let(x, y) % arrow(f) ^ arrow(g)
>
> -- Fun style
> fun(g) * fun(f) % let(x, y)
> ```

### `let(...)`

Creates a `Let` object that holds all provided values for use in a pipeline.

```lua
local let = require('luarrow').let
local values = let(10, 20)
```

**Parameters:**
- `...: unknown` - Any number of values to hold

**Returns:**
- `luarrow.Let` - Object holding the provided values

### `let(...) % arrow_or_fun` (Multi-Value Pipeline Entry)

Applies the held values to the given `Arrow` or `Fun` using the `%` operator, unpacking them as multiple arguments.

**Arrow style:**

```lua
local arrow = require('luarrow').arrow
local let = require('luarrow').let

-- Start a multi-value pipeline
local result = let(10, 20)
  % arrow(function(x, y) return x * 10, y * 20 end)
  ^ arrow(function(x, y) return tostring(x + y) end)
print(result)  -- "500"
```

**Fun style:**

```lua
local fun = require('luarrow').fun
local let = require('luarrow').let

local function scale(x, y) return x * 10, y * 20 end
local function format(x, y) return tostring(x + y) end

-- Apply multiple values at the end of a composition chain
local result = fun(format) * fun(scale) % let(10, 20)
print(result)  -- "500"
```

**Parameters:**
- `self: luarrow.Let` - The held values
- `f: luarrow.Arrow|luarrow.Fun` - The wrapped function to apply to

**Returns:**
- Result of calling `f:apply(...)` with the unpacked values

> [!NOTE]
> `let(x, y, ...) % f` is equivalent to `f:apply(x, y, ...)`.
> It provides cleaner syntax for multi-value pipeline entry points.

## 📋 `luarrow.utils.list` API Reference

The `luarrow.utils.list` module provides functional list manipulation utilities. All functions that accept additional arguments are **curried** — they return a `fun(xs: A[])` — so they compose directly with `arrow`:

```lua
local arrow = require('luarrow').arrow
local list = require('luarrow.utils.list')

local _ = { 1, 2, 3 }
  % arrow(list.map(function(x) return x + 10 end))
  ^ arrow(list.filter(function(x) return x % 2 ~= 0 end))
  ^ arrow(list.find(function(x) return x > 10 end))
  ^ arrow(print)  -- 11
```

### Basic Operations

#### `map(f)`

Apply a function to each element, producing a new list.

```lua
local doubled = list.map(function(x) return x * 2 end)({ 1, 2, 3 })
-- { 2, 4, 6 }

-- With arrow:
local _ = { 1, 2, 3 } % arrow(list.map(function(x) return x * 2 end))
```

**Parameters:**
- `f: fun(x: A): B` - Transformation function

**Returns:**
- `fun(xs: A[]): B[]`

---

#### `filter(pred)`

Keep elements that satisfy a predicate.

```lua
local evens = list.filter(function(x) return x % 2 == 0 end)({ 1, 2, 3, 4, 5 })
-- { 2, 4 }
```

**Parameters:**
- `pred: fun(x: A): boolean` - Predicate function

**Returns:**
- `fun(xs: A[]): A[]`

---

#### `flat_map(f)` / `concat_map(f)`

Map then flatten one level. `concat_map` is an alias.

```lua
local result = list.flat_map(function(x) return { x, x * 2 } end)({ 1, 2, 3 })
-- { 1, 2, 2, 4, 3, 6 }
```

**Parameters:**
- `f: fun(x: A): B[]` - Function returning a list

**Returns:**
- `fun(xs: A[]): B[]`

---

#### `flatten(list)`

Flatten one level of nesting.

```lua
local result = list.flatten({ { 1, 2 }, { 3, 4 }, { 5 } })
-- { 1, 2, 3, 4, 5 }
```

**Parameters:**
- `list: A[][]` - Nested list

**Returns:**
- `A[]`

---

#### `find(pred)`

Return the first element satisfying the predicate, or `nil`.

```lua
local first = list.find(function(x) return x > 3 end)({ 1, 2, 3, 4, 5 })
-- 4
```

**Parameters:**
- `pred: fun(x: A): boolean` - Predicate function

**Returns:**
- `fun(xs: A[]): A | nil`

---

### Fold Operations

#### `foldl(f, init)` / `reduce(f, init)`

Left fold with an initial accumulator. `reduce` is an alias.

```lua
local sum = list.foldl(function(acc, x) return acc + x end, 0)({ 1, 2, 3, 4 })
-- 10
```

**Parameters:**
- `f: fun(acc: B, x: A): B` - Fold function
- `init: B` - Initial accumulator

**Returns:**
- `fun(xs: A[]): B`

---

#### `foldr(f, init)`

Right fold with an initial accumulator.

```lua
local result = list.foldr(function(x, acc) return x .. acc end, 'd')({ 'a', 'b', 'c' })
-- 'abcd'
```

**Parameters:**
- `f: fun(x: A, acc: B): B` - Fold function
- `init: B` - Initial accumulator

**Returns:**
- `fun(xs: A[]): B`

---

#### `foldl1(f)`

Left fold without initial value (errors on empty list).

```lua
local product = list.foldl1(function(acc, x) return acc * x end)({ 2, 3, 4 })
-- 24
```

**Parameters:**
- `f: fun(acc: A, x: A): A` - Fold function

**Returns:**
- `fun(xs: A[]): A`

---

#### `foldr1(f)`

Right fold without initial value (errors on empty list).

```lua
local result = list.foldr1(function(x, acc) return x .. acc end)({ 'a', 'b', 'c' })
-- 'abc'
```

**Parameters:**
- `f: fun(x: A, acc: A): A` - Fold function

**Returns:**
- `fun(xs: A[]): A`

---

### Aggregation

#### `join(sep)`

Join a list of strings with a delimiter.

```lua
local result = list.join(', ')({ 'a', 'b', 'c' })
-- 'a, b, c'
```

**Parameters:**
- `sep: string` - Delimiter string

**Returns:**
- `fun(xs: string[]): string`

---

#### `sum(list)`

Sum all numeric elements.

```lua
list.sum({ 1, 2, 3, 4, 5 })  -- 15
list.sum({})  -- 0
```

**Parameters:**
- `list: number[]`

**Returns:**
- `number`

---

#### `product(list)`

Multiply all numeric elements.

```lua
list.product({ 2, 3, 4 })  -- 24
list.product({})  -- 1
```

**Parameters:**
- `list: number[]`

**Returns:**
- `number`

---

### Inspection

#### `length(list)`

Return the number of elements.

```lua
list.length({ 1, 2, 3 })  -- 3
```

**Parameters:**
- `list: A[]`

**Returns:**
- `integer`

---

#### `is_empty(list)`

Return `true` if the list has no elements.

```lua
list.is_empty({})    -- true
list.is_empty({ 1 }) -- false
```

**Parameters:**
- `list: A[]`

**Returns:**
- `boolean`

---

#### `head(list)`

Return the first element, or `nil` for an empty list.

```lua
list.head({ 1, 2, 3 })  -- 1
list.head({})            -- nil
```

**Parameters:**
- `list: A[]`

**Returns:**
- `A | nil`

---

#### `tail(list)`

Return all elements except the first.

```lua
list.tail({ 1, 2, 3, 4 })  -- { 2, 3, 4 }
list.tail({})               -- {}
```

**Parameters:**
- `list: A[]`

**Returns:**
- `A[]`

---

#### `last(list)`

Return the last element, or `nil` for an empty list.

```lua
list.last({ 1, 2, 3 })  -- 3
list.last({})            -- nil
```

**Parameters:**
- `list: A[]`

**Returns:**
- `A | nil`

---

#### `init(list)`

Return all elements except the last.

```lua
list.init({ 1, 2, 3, 4 })  -- { 1, 2, 3 }
```

**Parameters:**
- `list: A[]`

**Returns:**
- `A[]`

---

### Transformation

#### `reverse(list)`

Return a reversed copy of the list.

```lua
list.reverse({ 1, 2, 3 })  -- { 3, 2, 1 }
```

**Parameters:**
- `list: A[]`

**Returns:**
- `A[]`

---

#### `sort(list)`

Return a sorted copy using the default comparator.

```lua
list.sort({ 3, 1, 4, 1, 5 })  -- { 1, 1, 3, 4, 5 }
```

**Parameters:**
- `list: A[]`

**Returns:**
- `A[]`

---

#### `sort_by(key)` / `sort_with(key)`

Sort by key function or comparator. `sort_with` is an alias.

When called with a single-argument key function, elements are sorted by the key value.  
When called with a two-argument comparator returning boolean, it is used directly.

```lua
-- By key function
local items = { { name = 'b', v = 2 }, { name = 'a', v = 1 } }
local result = list.sort_by(function(x) return x.v end)(items)
-- { { name='a', v=1 }, { name='b', v=2 } }

-- By comparator (descending)
local result = list.sort_by(function(a, b) return a > b end)({ 3, 1, 2 })
-- { 3, 2, 1 }
```

> [!NOTE]
> If your key function accepts two arguments and returns a boolean, it will be detected as a comparator. Wrap it to avoid this: `sort_by(function(x) return key_fn(x) end)`.

**Parameters:**
- `key: fun(x: A): K | fun(a: A, b: A): boolean`

**Returns:**
- `fun(xs: A[]): A[]`

---

#### `unique(list)`

Remove duplicates, keeping the first occurrence of each value.

```lua
list.unique({ 1, 2, 2, 3, 1, 4 })  -- { 1, 2, 3, 4 }
```

**Parameters:**
- `list: A[]`

**Returns:**
- `A[]`

---

#### `group_by(f)`

Group elements by the value returned by `f`.

```lua
local groups = list.group_by(function(x) return x % 2 end)({ 1, 2, 3, 4, 5, 6 })
-- groups[0] = { 2, 4, 6 }  (even)
-- groups[1] = { 1, 3, 5 }  (odd)
```

**Parameters:**
- `f: fun(x: A): K` - Key function

**Returns:**
- `fun(xs: A[]): table<K, A[]>`

---

### Search

#### `maximum(list)`

Return the largest element (errors on empty list).

```lua
list.maximum({ 3, 1, 4, 1, 5 })  -- 5
```

**Parameters:**
- `list: number[]`

**Returns:**
- `number`

---

#### `minimum(list)`

Return the smallest element (errors on empty list).

```lua
list.minimum({ 3, 1, 4, 1, 5 })  -- 1
```

**Parameters:**
- `list: number[]`

**Returns:**
- `number`
