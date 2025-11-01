local M = {}

---The wrapper of a function from A to B.
---Contains **the Haskell style function composition system**:
---```lua
---fun(f) * fun(g) % x
---````
---which is equivalent to
---```lua
---f(g(x))
---```
---
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
  local self_raw = self.raw
  local g_raw = g.raw
  return Fun.new(function(x)
    return self_raw(g_raw(x))
  end)
end

Fun.__mul = Fun.compose

---NOTE: `===` means "is equivalent to"
---```
---fun(f):apply(x) -- luarrow (method call)
---===
---fun(f) % x -- luarrow (operator call)
---===
---f(x) -- Pure Lua
---===
---f $ x -- Haskell
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
  ---@type Fun<unknown, unknown> -- unknown because limitation of LuaCATS
  local self = setmetatable({}, Fun)
  self.raw = func
  return self
end

M.fun = Fun.new

---**Wrapped value for Haskell-style operations**!
---
---Allows using unwrapped functions in Haskell-style operations:
---
---```lua
---local result = fun.wrap(42) % f
---```
---which is equivalent to
---```lua
---local result = f(42)
---```
---
---@generic A
---@class FunValue<A> : { value: A }
local FunValue = {}
FunValue.__index = FunValue

---Exposes for users
---@alias luarrow.FunValue FunValue

---Apply a function to the wrapped value and return the result (unwrapped).
---This is the terminal operation that extracts the value.
---
---```lua
---fun.wrap(42) % f  -- returns f(42), not wrapped
---```
---@generic A, B
---@param self FunValue<A>
---@param f fun(x: A): B | Fun<A, B>
---@return B
function FunValue:apply_final(f)
  if type(f) == 'function' then
    return f(self.value)
  else
    -- f is a Fun, use its raw function
    return f.raw(self.value)
  end
end

FunValue.__mod = FunValue.apply_final

---@generic A
---@param value A
---@return FunValue<A>
function FunValue.new(value)
  ---@type FunValue<unknown>
  local self = setmetatable({}, FunValue)
  self.value = value
  return self
end

M.wrap = FunValue.new

return M
