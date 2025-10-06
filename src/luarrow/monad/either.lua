local M = {}

---The Either monad - represents computations that may fail with an error.
---An Either value can be either Right(value) (success) or Left(error) (failure).
---
---@generic E, A
---@class Either<E, A> : { is_right: boolean, value?: A, error?: E }
---
---@see Either.fmap
---@see Either.bind
---@see Either.or_else
local Either = {}
Either.__index = Either

---Exposes for users
---@alias luarrow.Either Either

---Functor map (fmap in Haskell).
---Maps a function over the wrapped value if it's Right.
---If the Either is Left, returns Left unchanged.
---```
---Right(x):fmap(f) -> Right(f(x))
---Left(e):fmap(f) -> Left(e)
---```
---@generic E, A, B
---@param self Either<E, A>
---@param f fun(x: A): B
---@return Either<E, B>
function Either:fmap(f)
  if not self.is_right then
    return Either.left(self.error)
  end
  return Either.right(f(self.value))
end

Either.__mul = Either.fmap

---Monadic bind (>>= in Haskell).
---Chains Either computations.
---```
---Right(x):bind(f) -> f(x)
---Left(e):bind(f) -> Left(e)
---```
---@generic E, A, B
---@param self Either<E, A>
---@param f fun(x: A): Either<E, B>
---@return Either<E, B>
function Either:bind(f)
  if not self.is_right then
    return Either.left(self.error)
  end
  return f(self.value)
end

Either.__mod = Either.bind

---Returns the wrapped value if Right, otherwise returns the default value.
---@generic E, A
---@param self Either<E, A>
---@param default A
---@return A
function Either:or_else(default)
  if self.is_right then
    return self.value
  end
  return default
end

---Checks if the Either is Left (contains an error).
---@param self Either
---@return boolean
function Either:is_left()
  return not self.is_right
end

---Maps a function over the error value if it's Left.
---If the Either is Right, returns Right unchanged.
---@generic E, E2, A
---@param self Either<E, A>
---@param f fun(e: E): E2
---@return Either<E2, A>
function Either:map_left(f)
  if self.is_right then
    return Either.right(self.value)
  end
  return Either.left(f(self.error))
end

---Create a Right value (an Either that contains a success value).
---@generic E, A
---@param value A
---@return Either<E, A>
function Either.right(value)
  ---@type Either<unknown, unknown>
  local self = setmetatable({}, Either)
  self.is_right = true
  self.value = value
  return self
end

---Create a Left value (an Either that contains an error).
---@generic E, A
---@param error E
---@return Either<E, A>
function Either.left(error)
  ---@type Either<unknown, unknown>
  local self = setmetatable({}, Either)
  self.is_right = false
  self.error = error
  return self
end

M.right = Either.right
M.left = Either.left
M.Either = Either

return M
