<div align="center">
<h1>[→] luarrow [→]</h1>
<div><code>|></code> <b>The true Pipeline-operator</b> <code>|></code></div>
<div><code>.</code><code>$</code> <b>The Haskell-inspired function compositions</b> <code>.</code><code>$</code></div>
<div><code>*</code><code>%</code> The new syntax for Lua, and you <code>^</code><code>%</code></div>
</div>

## 🚗 Quick Examples

Powered by Lua's beautiful operator overloading (of `%`, `*`, `^`), bringing you the elegance of:

- OCaml, Julia, F#, PHP, Elixir, Elm's **true** pipeline **operators** `x |> f |> g` -- Unlike `pipe(x, f, g)` (cheap pipe **function**)[^php-pipeline-operator]
    - The beauty of the pipeline operator hardly needs mentioning here

[^php-pipeline-operator]: To be precise, a pipeline operator RFC has been submitted for PHP 8.5. [Reference](https://wiki.php.net/rfc/pipe-operator-v3)

```lua
local arrow = require('luarrow').arrow

-- The **true** pipeline operator
local _ = 42
  % arrow(function(x) return x - 2 end)
  ^ arrow(function(x) return x * 10 end)
  ^ arrow(function(x) return x + 1 end)
  ^ arrow(print)  -- 401
```

Equivalent to: [^why-local-underscore]

[^why-local-underscore]: In Lua, expressions cannot stand alone at the top level - they must be part of a statement. The `local _ =` assigns the result to an unused variable (indicated by `_`, a common convention), allowing the pipeline expression to be valid Lua syntax.

```php
// PHP
42
  |> (fn($x) => $x - 2)
  |> (fn($x) => $x * 10)
  |> (fn($x) => $x + 1)
  |> var_dump(...);
```

- Haskell's **highly readable** `f . g . h $ x` syntax -- Unlike `f(g(h(x)))` (too many parentheses!)
    - This notation is also used in mathematics, and similarly, it is a very beautiful syntax

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
print . f . g . h $ 42
```

Detailed documentation can be found in [`./luarrow.lua/doc/`](./luarrow.lua/doc/) directory.

## ✨ Why luarrow?

Write **dramatically** cleaner, more expressive Lua code:

- **Beautiful code** - Make your functional pipelines readable and maintainable
- **Elegant composition** - Chain multiple functions naturally with `*`/`^` operators
    - **True pipeline operators** - Transform data with intuitive left-to-right flow `x % f ^ g`
    - **Haskell-inspired syntax** - Write `f * g % x` instead of `f(g(x))`
- **Zero dependencies** - Pure Lua implementation with no external dependencies
- **Excellent performance** - In LuaJIT environments (like Neovim), pre-composed functions have **virtually no overhead** compared to pure Lua
    - See [Performance Benchmarks](luarrow.lua/doc/examples.md#-performance-considerations) for detailed results

> [!NOTE]
> **About the name:**
>
> "luarrow" is a portmanteau of "Lua" + "arrow", where "arrow" refers to the function arrow (→) commonly used in mathematics and functional programming to denote functions (`A → B`).

## 🚀 Getting Started

### Pipeline-Style Composition [^pipeline-introduction]

[^pipeline-introduction]: Are you a new comer for the pipeline operator? Alright! The pipeline operator is a very simple idea. For easy understanding, you can find a lot of documentations if you google it. Or for the detail, my recommended documentation is ['PHP RFC: Pipe operator v3'](https://wiki.php.net/rfc/pipe-operator-v3).

If you prefer left-to-right (`→`) data flow (like the `|>` operator in OCaml/Julia/F#/Elixir/Elm), use `arrow`, `%`, and `^`:

```lua
local arrow = require('luarrow').arrow

-- Pipeline style: data flows left to right
local _ = 42
  % arrow(function(x) return x - 2 end)
  ^ arrow(function(x) return x * 10 end)
  ^ arrow(function(x) return x + 1 end)
  ^ arrow(print)  -- 401
-- Evaluation: minus_two(42) = 40
--             times_ten(40) = 400
--             add_one(400) = 401
```

> [!TIP]
> **Alternative styles:**
>
> You can also use these styles if you prefer:
>
> ```lua
> -- Store the result and print separately
> local result = 42
>   % arrow(function(x) return x - 2 end)
>   ^ arrow(function(x) return x * 10 end)
>   ^ arrow(function(x) return x + 1 end)
> print(result)  -- 401
>
> -- Or wrap the entire pipeline in print()
> print(
>   42
>     % arrow(function(x) return x - 2 end)
>     ^ arrow(function(x) return x * 10 end)
>     ^ arrow(function(x) return x + 1 end)
> )  -- 401
> ```

- [Method-Style API is also available](./luarrow.lua/doc/api.md)

### Haskell-Style Composition

If you prefer right-to-left  (`←`) data flow (like the `.` and the `$` operator in Haskell), use `fun`, `%`, and `*`:

```lua
local fun = require('luarrow').fun

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

> [!TIP]
> This function composition `f * g` is the mathematical notation `f ∘ g`.

> [!TIP]
> 🤫 Secret Notes:  
> Actually, the function composition part `f ^ g` of the pipeline operator is also used in some areas of mathematics as `f ; g`.

- [Method-Style API is also available](./luarrow.lua/doc/api.md)

### Pipeline-Style vs Haskell-Style

Both `arrow` and `fun` produce the same results but with different syntax:
- `arrow`: Pipeline style -- `x % arrow(f) ^ arrow(g)` (data flows left-to-right)
- `fun`: Mathematical style -- `fun(f) * fun(g) % x` (compose right-to-left, apply at end)

So how should we use it differently?  
Actually, Haskell-Style is not in vogue in languages other than Haskell.  
So, 📝 **"basically", we recommend Pipeline-Style** 📝, which is popular in many languages.

However, Haskell-Style is still really useful.  
For example, Point-Free-Style.

See below for more information on Point-Free-Style:
- [Real-World Examples > Data Transformation Pipeline](#point-free-style-example)
- [examples.md > Point-Free-Style](luarrow.lua/doc/examples.md#about-point-free-style)

But when it comes down to it, ✨**choose whichever you want to write**✨.  
luarrow aims to make your programming entertaining!

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

For complete API documentation, see **[luarrow.lua/doc/api.md](luarrow.lua/doc/api.md)**.

For practical examples and use cases, see **[luarrow.lua/doc/examples.md](luarrow.lua/doc/examples.md)**.

**Quick reference for `fun`:**
- `fun(f)` -- Wrap a function for composition
- `f * g` -- Compose two functions in mathematical order (`f ∘ g`)
- `f % x` -- Apply function to value in Haskell-Style

**Quick reference for `arrow`:**
- `arrow(f)` -- Wrap a function for pipeline
- `f ^ g` -- Compose two functions in pipeline order (`f |> g`)
- `x % f` -- Apply function to value in Pipeline-Style

## 🔄 Comparison Haskell-Style with Real Haskell

| Haskell | luarrow | Pure Lua |
|-|-|-|
| `let k = f . g` | `local k = fun(f) * fun(g)` | `local function k(x) return f(g(x)) end` |
| `f . g . h $ x` | `fun(f) * fun(g) * fun(h) % x` | `f(g(h(x)))` |

The syntax is remarkably close to Haskell's elegance, while staying within Lua's operator overloading capabilities!

## 🔄 Comparison Pipeline-Style with PHP

| PHP | luarrow | Pure Lua |
|-|-|-|
| `$x \|> $f \|> $g \|> var_dump` | `x % arrow(f) ^ arrow(g) ^ arrow(print)` | `print(g(f(x)))` |

The syntax is remarkably close to general language's elegant pipeline operator, too!

> [!NOTE]
> PHP's pipeline operator is shown as a familiar comparison example.
> Currently, this PHP syntax is at the RFC stage.

## 💡 Real-World Examples

### Data Transformation Pipeline (`fun`)

```lua
local fun = require('luarrow').fun

local trim = function(s) return s:match("^%s*(.-)%s*$") end
local uppercase = function(s) return s:upper() end
local add_prefix = function(s) return "USER: " .. s end

local process_username = fun(add_prefix) * fun(uppercase) * fun(trim)

local username = process_username % "  alice  "
print(username)  -- "USER: ALICE"
```

<a name="point-free-style-example"></a>

> [!IMPORTANT]
> This definition style for `process_username` is what Haskell programmers call '**Point-Free Style**'!  
> In Haskell, this is a very common technique to reduce the amount of code and improve readability.

### Numerical Computations (`arrow`)

```lua
local arrow = require('luarrow').arrow

local _ = 5
  % arrow(function(x) return -x end)
  ^ arrow(function(x) return x + 10 end)
  ^ arrow(function(x) return x * x end)
  ^ arrow(print)  -- 25
```

### List Processing (`fun`)

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
print(result) -- { 4, 8, 12 }
```

## 📖 Documentation

- **[API Reference](luarrow.lua/doc/api.md)** - Complete API documentation
- **[Examples](luarrow.lua/doc/examples.md)** - Practical examples and use cases

## 🙏 Acknowledgments

Inspired by Haskell's elegant function composition and the power of operator overloading in Lua.

## 💭 Philosophy

> "The best code is code that reads like poetry."

luarrow brings functional programming elegance to Lua, making your code more expressive, composable, and maintainable.
Whether you're building data pipelines, processing lists, or creating complex transformations, luarrow makes your intent crystal clear.

- - - - -

Like this project?  
Give it a ⭐ to show your support!

**Happy programming!** 🎯

- - - - -

<!-- Footnotes will render at here -->
