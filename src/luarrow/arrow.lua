local M = {}

---**The enhanced pipleine operator**!
---
---Simular to `Fun<A, B>`, but the direction of composition is different.
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
---
---@see Arrow.to
---@see Arrow.apply
local Arrow = {}
Arrow.__index = Arrow

---Exposes for users
---@alias luarrow.Arrow Arrow

---NOTE: `===` means "is equivalent to"
---```
---arrow(f):to(arrow(g)) -- luarrow (method call)
---===
---arrow(f) ^ arrow(g) -- luarrow (operator call)
---===
---arrow(function(x) return g(f(x)) end) -- Pure Lua (Note that the order of f and g is different from `Fun`)
---===
---f <<< g -- Haskell [Control.Arrow.<<<](https://hackage.haskell.org/package/base-4.21.0.0/docs/Control-Arrow.html#v:-60--60--60-)
---===
---f ; g -- Mathematics
---```
---@generic A, B, C
---@param self Arrow<A, B>
---@param g Arrow<B, C>
---@return Arrow<A, C>
function Arrow:to(g)
  return Arrow.new(function(x)
    return g.raw(self.raw(x))
  end)
end

Arrow.__pow = Arrow.to

---Same as `Fun.apply()`
---@see Arrow.apply
---```
---arrow(f):apply(x) -- luarrow (method call)
---===
---x % arrow(f) -- luarrow (operator call). Note that
---===
---f(x) -- Pure Lua
---```
---@generic A, B
---@param self Arrow<A, B>
---@param x A
---@return B
---
---Note that `%` operator implementation is tricky.
---It is not same as this.
---@see Arrow.__mod
function Arrow:apply(x)
  return self.raw(x)
end

---```lua
---local result = x % arrow(raw_f)
---```
---
---@generic A, B
---@param x A
---@param f Arrow<A, B>
---@return B
---
---Evaluation (Why this definition is tricky?):
---```lua
---x % f
----- Try to call metamethod __mod of x
---(__mod of x)(x, f) -- but f is not a number
----- Then, fallback to Arrow.__mod
---Arrow.__mod(x, f)
----- End
---```
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
