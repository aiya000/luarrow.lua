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
---@generic A, B, C
---@param self Arrow<A, B>
---@param g Arrow<B, C>
---@return Arrow<A, C>
function Arrow:compose_to(g)
  -- To optimize performance, assign to variables outside
  local self_raw = self.raw
  local g_raw = g.raw
  return Arrow.new(function(x)
    return g_raw(self_raw(x))
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
---@generic A, B
---@param self Arrow<A, B>
---@param x A
---@return B
function Arrow:apply(x)
  return self.raw(x)
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

---**Wrapped value for pipeline operations**!
---
---Allows using unwrapped functions in pipeline operations:
---
---```lua
---local result = arrow.wrap(42)
---  % f
---  ^ g
---```
---which is equivalent to
---```lua
---local result = g(f(42))
---```
---
---@generic A
---@class ArrowValue<A> : { value: A }
local ArrowValue = {}
ArrowValue.__index = ArrowValue

---Exposes for users
---@alias luarrow.ArrowValue ArrowValue

---Apply a function to the wrapped value and return a new wrapped value.
---This allows chaining with the % operator.
---
---```lua
---arrow.wrap(42) % f % g  -- returns arrow.wrap(g(f(42)))
---```
---@generic A, B
---@param self ArrowValue<A>
---@param f fun(x: A): B | Arrow<A, B>
---@return ArrowValue<B>
function ArrowValue:apply_and_wrap(f)
  if type(f) == 'function' then
    return ArrowValue.new(f(self.value))
  else
    -- f is an Arrow, use its raw function
    return ArrowValue.new(f.raw(self.value))
  end
end

---Apply a function to the wrapped value and return the result (unwrapped).
---This is the terminal operation that extracts the value.
---
---```lua
---arrow.wrap(42) % f ^ g  -- Because ^ has higher precedence, this becomes:
---                        --   arrow.wrap(42) % (f ^ g) which won't work.
---                        -- Use: (arrow.wrap(42) % f) ^ g to unwrap at the end.
---```
---@generic A, B
---@param self ArrowValue<A>
---@param f fun(x: A): B | Arrow<A, B>
---@return B
function ArrowValue:apply_final(f)
  if type(f) == 'function' then
    return f(self.value)
  else
    -- f is an Arrow, use its raw function
    return f.raw(self.value)
  end
end

ArrowValue.__mod = ArrowValue.apply_and_wrap
ArrowValue.__pow = ArrowValue.apply_final

-- Allow the wrapped value to be used in string contexts
ArrowValue.__tostring = function(self)
  return tostring(self.value)
end

-- Allow the wrapped value to be used in numeric contexts
ArrowValue.__tonumber = function(self)
  return tonumber(self.value)
end

-- Allow the wrapped value to be used in comparison contexts
ArrowValue.__eq = function(self, other)
  if getmetatable(other) == ArrowValue then
    return self.value == other.value
  else
    return self.value == other
  end
end

ArrowValue.__lt = function(self, other)
  if getmetatable(other) == ArrowValue then
    return self.value < other.value
  else
    return self.value < other
  end
end

ArrowValue.__le = function(self, other)
  if getmetatable(other) == ArrowValue then
    return self.value <= other.value
  else
    return self.value <= other
  end
end

---@generic A
---@param value A
---@return ArrowValue<A>
function ArrowValue.new(value)
  ---@type ArrowValue<unknown>
  local self = setmetatable({}, ArrowValue)
  self.value = value
  return self
end

M.wrap = ArrowValue.new

return M
