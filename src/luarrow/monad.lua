local M = {}

---A wrapper for values in a monadic/applicative context.
---Supports **Applicative style function application**:
---```lua
---pure(f) * pure(g) % m
---```
---which applies the composed function to the monadic value.
---
---@generic A
---@class Pure<A> : { value: A }
---
---@see Pure.fmap
---@see Pure.apply
local Pure = {}
Pure.__index = Pure

---Exposes for users
---@alias luarrow.Pure Pure

---Functor map (fmap in Haskell).
---Maps a function over the wrapped value.
---```
---pure(f):fmap(pure(g)) -- luarrow (method call)
---===
---pure(f) * pure(g) -- luarrow (operator call)
---===
---pure(f . g) -- Conceptually, function composition in applicative context
---```
---@generic A, B, C
---@param self Pure<fun(x: B): C>
---@param mg Pure<fun(x: A): B>
---@return Pure<fun(x: A): C>
function Pure:fmap(mg)
  local f = self.value
  local g = mg.value
  return Pure.new(function(x)
    return f(g(x))
  end)
end

Pure.__mul = Pure.fmap

---Applicative application.
---Applies the wrapped function to a regular value.
---```
---pure(f):apply(x) -- luarrow (method call)
---===
---pure(f) % x -- luarrow (operator call)
---===
---f(x) -- Pure Lua
---===
---f <$> pure x -- Haskell (with pure wrapping)
---```
---@generic A, B
---@param self Pure<fun(x: A): B>
---@param x A
---@return B
function Pure:apply(x)
  return self.value(x)
end

Pure.__mod = Pure.apply

---Wrap a value in the Pure applicative context.
---@generic A
---@param value A
---@return Pure<A>
function Pure.new(value)
  ---@type Pure<unknown> -- unknown because limitation of LuaCATS
  local self = setmetatable({}, Pure)
  self.value = value
  return self
end

---Wrap a value in the Pure applicative context.
---This is the main entry point for users.
---@generic A
---@param value A
---@return Pure<A>
M.pure = Pure.new

M.Pure = Pure

return M
