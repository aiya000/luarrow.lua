local M = {}

---The Identity monad - a wrapper for values in a monadic/applicative context.
---Supports **Applicative style function application**:
---```lua
---identity(f) * identity(g) % m
---```
---which applies the composed function to the monadic value.
---
---@generic A
---@class Identity<A> : { value: A }
---
---@see Identity.fmap
---@see Identity.apply
local Identity = {}
Identity.__index = Identity

---Exposes for users
---@alias luarrow.Identity Identity

---Functor map (fmap in Haskell).
---Maps a function over the wrapped value.
---```
---identity(f):fmap(identity(g)) -- luarrow (method call)
---===
---identity(f) * identity(g) -- luarrow (operator call)
---===
---identity(f . g) -- Conceptually, function composition in applicative context
---```
---@generic A, B, C
---@param self Identity<fun(x: B): C>
---@param mg Identity<fun(x: A): B>
---@return Identity<fun(x: A): C>
function Identity:fmap(mg)
  local f = self.value
  local g = mg.value
  return Identity.new(function(x)
    return f(g(x))
  end)
end

Identity.__mul = Identity.fmap

---Applicative application.
---Applies the wrapped function to a regular value.
---```
---identity(f):apply(x) -- luarrow (method call)
---===
---identity(f) % x -- luarrow (operator call)
---===
---f(x) -- Pure Lua
---===
---f <$> pure x -- Haskell (with pure wrapping)
---```
---@generic A, B
---@param self Identity<fun(x: A): B>
---@param x A
---@return B
function Identity:apply(x)
  return self.value(x)
end

Identity.__mod = Identity.apply

---Wrap a value in the Identity monad.
---@generic A
---@param value A
---@return Identity<A>
function Identity.new(value)
  ---@type Identity<unknown> -- unknown because limitation of LuaCATS
  local self = setmetatable({}, Identity)
  self.value = value
  return self
end

---Wrap a value in the Identity monad.
---This is the main entry point for users.
---@generic A
---@param value A
---@return Identity<A>
M.identity = Identity.new

M.Identity = Identity

return M
