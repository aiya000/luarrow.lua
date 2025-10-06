local M = {}

---The Maybe monad - represents optional values.
---A Maybe value can either be Just(value) or Nothing.
---
---@generic A
---@class Maybe<A> : { is_just: boolean, value?: A }
---
---@see Maybe.fmap
---@see Maybe.bind
---@see Maybe.or_else
local Maybe = {}
Maybe.__index = Maybe

---Exposes for users
---@alias luarrow.Maybe Maybe

---Functor map (fmap in Haskell).
---Maps a function over the wrapped value if it exists.
---If the Maybe is Nothing, returns Nothing.
---```
---Just(x):fmap(f) -> Just(f(x))
---Nothing:fmap(f) -> Nothing
---```
---@generic A, B
---@param self Maybe<A>
---@param f fun(x: A): B
---@return Maybe<B>
function Maybe:fmap(f)
  if not self.is_just then
    return Maybe.nothing()
  end
  return Maybe.just(f(self.value))
end

Maybe.__mul = Maybe.fmap

---Monadic bind (>>= in Haskell).
---Chains Maybe computations.
---```
---Just(x):bind(f) -> f(x)
---Nothing:bind(f) -> Nothing
---```
---@generic A, B
---@param self Maybe<A>
---@param f fun(x: A): Maybe<B>
---@return Maybe<B>
function Maybe:bind(f)
  if not self.is_just then
    return Maybe.nothing()
  end
  return f(self.value)
end

Maybe.__mod = Maybe.bind

---Returns the wrapped value if Just, otherwise returns the default value.
---@generic A
---@param self Maybe<A>
---@param default A
---@return A
function Maybe:or_else(default)
  if self.is_just then
    return self.value
  end
  return default
end

---Checks if the Maybe is Just.
---@param self Maybe
---@return boolean
function Maybe:is_nothing()
  return not self.is_just
end

---Create a Just value (a Maybe that contains a value).
---@generic A
---@param value A
---@return Maybe<A>
function Maybe.just(value)
  ---@type Maybe<unknown>
  local self = setmetatable({}, Maybe)
  self.is_just = true
  self.value = value
  return self
end

---Create a Nothing value (a Maybe that contains no value).
---@generic A
---@return Maybe<A>
function Maybe.nothing()
  ---@type Maybe<unknown>
  local self = setmetatable({}, Maybe)
  self.is_just = false
  return self
end

M.just = Maybe.just
M.nothing = Maybe.nothing
M.Maybe = Maybe

return M
