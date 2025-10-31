local M = {}

---**The enhanced pipeline operator**!
---
---Similar to `Fun<A, B>`, but the direction of composition is different.
---Contains '**the Arrow version**' '**Haskell style function composition system**':
---
---```lua
---local result =
---  x
---  % arrow(f)
---  ^ arrow(g)
---  ^ arrow(h)
---```
---which is equivalent to
---```lua
---local result = h(g(f(x)))
---```
---
---@generic A, B
---@class Arrow<A, B> : { raw: fun(x: A): B }
local Arrow = {}
Arrow.__index = Arrow

---Exposes for users
---@alias luarrow.Arrow Arrow

---NOTE: `===` means "is equivalent to"
---```
---arrow(f):compose_to(arrow(g)) -- luarrow (method call)
---===
---arrow(f) ^ arrow(g) -- luarrow (operator call)
---===
---arrow(function(x) return g(f(x)) end) -- Pure Lua (Note that the order of f and g is different from `Fun`)
---===
---f <<< g -- Haskell [Control.Arrow.<<<](https://hackage.haskell.org/package/base-4.21.0.0/docs/Control-Arrow.html#v:-60--60--60-)
---===
---f ; g -- Mathematics
---```
---
---Note: Composition supports multiple arguments and return values.
---Functions in the composition chain can accept and return multiple values.
---
---@generic A, B, C
---@param self Arrow<A, B>
---@param g Arrow<B, C>
---@return Arrow<A, C>
function Arrow:compose_to(g)
  -- To optimize performance, assign to variables outside
  local self_raw = self.raw
  local g_raw = g.raw
  return Arrow.new(function(...)
    return g_raw(self_raw(...))
  end)
end

Arrow.__pow = Arrow.compose_to

---Same as `Fun.apply()`
---@see Arrow.__mod
---
---NOTE: `===` means "is equivalent to"
---```
---arrow(f):apply(x) -- luarrow (method call)
---===
---x % arrow(f) -- luarrow (operator call)
---===
---f(x) -- Pure Lua
---```
---
---Note: This method supports multiple arguments and return values.
---Example: `arrow(f):apply(x, y, z)` will call `f(x, y, z)` and return all values.
---
---@generic A, B
---@param self Arrow<A, B>
---@param ... A Variadic arguments passed to the wrapped function
---@return B ... Variadic return values from the wrapped function
function Arrow:apply(...)
  return self.raw(...)
end

---```lua
---local result = x % arrow(raw_f)
---```
---@generic A, B
---@param x A
---@param f Arrow<A, B>
---@return B
Arrow.__mod = function(x, f)
  return f:apply(x)
end

---@generic A, B
---@param func fun(x: A): B
---@return Arrow<A, B>
function Arrow.new(func)
  ---@type Arrow<unknown, unknown> -- unknown because limitation of LuaCATS
  local self = setmetatable({}, Arrow)
  self.raw = func
  return self
end

M.arrow = Arrow.new

return M
