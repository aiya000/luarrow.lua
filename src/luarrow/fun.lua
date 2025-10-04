local M = {}

---The wrapper of a function from A to B.
---Contains **the Haskell stlye function composition system**:
---`fun(f) * fun(g) % x`
---@generic A, B
---@class Fun<A, B> : { raw: fun(x: A): B }
---
---@see Fun.compose
---@see Fun.apply
local Fun = {}
Fun.__index = Fun

---Exposes for users
---@alias luarrow.Fun Fun

---NOTE: `===` means "is equivalent to"
---```
---fun(f):compose(fun(g)) -- luarrow (method call)
---===
---fun(f) .. fun(g) -- luarrow (operator call)
---===
---fun(function(x) return f(g(x)) end) -- Pure Lua
---===
---f . g -- Haskell
---===
---f ∘ g -- Mathematics
---```
---@generic A, B, C
---@param self Fun<A, B>
---@param g Fun<B, C>
---@return Fun<A, C>
function Fun:compose(g)
  return Fun.new(function(x)
    return self.raw(g.raw(x))
  end)
end

Fun.__mul = Fun.compose

---NOTE: `===` means "is equivalent to"
---```
---fun(f):apply(x) -- luarrow (method call)
---===
---f(x) -- Pure Lua
---```
---@generic A, B
---@param self Fun<A, B>
---@param x A
---@return B
function Fun:apply(x)
  return self.raw(x)
end

Fun.__mod = Fun.apply

---@generic A, B
---@param func fun(x: A): B
---@return Fun<A, B>
function Fun.new(func)
  local self = setmetatable({}, Fun)
  ---@diagnostic disable-next-line -- TODO: なぜか怒られるので、直すか、強制する
  self.raw = func
  return self
end

M.fun = Fun.new

return M
