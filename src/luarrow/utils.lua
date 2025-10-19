local M = {}

---Compatibility for Lua 5.1 and 5.2+
local unpack = unpack or table.unpack

---@see partial
---@param accumulated table
---@param f function
---@param arity number | nil
---@return function
local function make_partial(accumulated, f, arity)
  return function(...)
    local args = { ... }
    local new_accumulated = {}

    -- Copy accumulated arguments
    for i, v in ipairs(accumulated) do
      new_accumulated[i] = v
    end

    -- Add new arguments
    for _, v in ipairs(args) do
      table.insert(new_accumulated, v)
    end

    -- If we have enough arguments, call the original function
    if arity ~= nil and #new_accumulated >= arity then
      return f(unpack(new_accumulated))
    end

    -- Try to call the function to see if we have enough arguments
    local success, result = pcall(f, unpack(new_accumulated))
    if success then
      return result
    end

    -- Not enough arguments yet, return a new partial function
    return make_partial(new_accumulated, f, arity)
  end
end

---Creates a partially applicable version of the given function.
---Allows flexible argument passing: one at a time, multiple at once, or all at once.
---
---IMPORTANT: This function may not work correctly with:
---1. C functions (Lua built-in functions or functions written in C)
---2. JIT-compiled functions (in LuaJIT, debug information may be lost)
---3. Variadic-only functions (functions with only `...` parameters)
---
---For these cases, please explicitly specify the `arity` parameter, or use `curry()`.
---
---@param f function --The function to make partially applicable
---@param arity number | nil --Optional number of arguments (defaults to function arity)
---@return function --The partially applicable function
---
---```lua
---local add = partial(function(a, b, c)
---  return a + b + c
---end)
---
---add(1)(2)(3) -- returns 6
---add(1, 2)(3) -- also returns 6
---add(1, 2, 3) -- also returns 6
---```
---
---This is especially useful when combined with `fun()` and `arrow()`:
---
---```lua
----- When you have some useful functions:
---local function plus(a, b, c)
---  return a + b + c -- Just an example of a useful function
---end
---
---local function multiply(x, y)
---  return x * y -- This is also an example of a useful function
---end
---```
---
---You can partially apply them with `fun()` or `arrow()`.
---This means you don't need to wrap them like `function(x) return foo(1, 2, x) end` or similar:
---
---```lua
---local arrow = require('luarrow').arrow
---local partial = require('luarrow.utils').partial
---
---local result = 42
---  % arrow(partial(plus)(10, 20)) -- (10 + 20) + 42
---  ^ arrow(partial(multiply)(100)) -- (previous_result) * 100
---```
---
---This is somewhat similar to Scala's `plus(10, 20, _)` and `multiply(100, _)` syntax.
function M.partial(f, arity)
  if arity == nil then
    local info = debug.getinfo(f, 'u')
    if not info then
      error(
        'partial: Cannot determine function arity automatically. '
          .. 'This may occur when:\n'
          .. '  1. The function is a C function (Lua built-in or C extension)\n'
          .. '  2. The function is JIT-compiled (debug info lost in LuaJIT)\n'
          .. '  3. The function uses only variadic parameters (...)\n'
          .. "Please specify the 'arity' parameter explicitly."
      )
    end

    arity = info.nparams

    if arity == 0 and info.isvararg then
      error(
        'partial: Cannot determine function arity automatically. '
          .. 'The function appears to use only variadic parameters (...).\n'
          .. "Please specify the 'arity' parameter explicitly."
      )
    end
  end
  return make_partial({}, f, arity)
end

---Same as `partial()`, but only accept to functions what have just two arguments.
---This is the traditional currying function from programming history.
---@generic A, B, C
---@param f fun(a: A, b: B): C
---@return fun(a: A): fun(b: B): C
function M.curry(f)
  return M.partial(f, 2)
end

---Swaps the first and the two argument of a function.
---@generic A, B, C
---@param f fun(a: A, b: B): C
---@return fun(b: B, a: A): C
function M.swap(f)
  return function(b, a)
    return f(a, b)
  end
end

return M
