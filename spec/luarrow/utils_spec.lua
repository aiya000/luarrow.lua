local utils = require('luarrow.utils')
local curry = utils.curry
local partial = utils.partial
local swap = utils.swap

local function two_args_func(a, b)
  return a + b
end

describe('utils.partial', function()
  local function three_args_func(a, b, c)
    return a + b + c
  end

  local function variadic_args_func(...)
    local args = {...}
    local result = 1
    for _, v in ipairs(args) do
      result = result * v
    end
    return result
  end

  -- Note for Pure Lua programmers. This `X -> ... -> Z` notation is Haskell's.
  -- Using for easy to read.
  -- Please see some references about the Haskell's function notation.
  it('should extract `(X, Y) -> Z` to `X -> Y -> Z`', function()
    local add = partial(two_args_func)
    assert.are.equal(add(1)(2), 3)
  end)

  it('should extract `(X, Y, Z) -> A` to `X -> Y -> Z -> A`', function()
    local add = partial(three_args_func)
    assert.are.equal(add(1)(2)(3), 6)
  end)

  it('should extract `(X, Y, Z) -> A` to `(X, Y) -> Z -> A`', function()
    local add = partial(three_args_func)
    assert.are.equal(add(1, 2)(3), 6)
  end)

  it('should extract `(X, Y, Z) -> A` to `(X, Y, Z) -> A` (same type functions)', function()
    local add = partial(three_args_func)
    assert.are.equal(add(1, 2, 3), 6)
  end)

  it('should work with different data types', function()
    local concat = partial(function(a, b, c)
      return a .. b .. c
    end)
    local result = concat("Hello")(" ")("World")
    assert.are.equal(result, "Hello World")
  end)
end)

describe('utils.curry', function()
  it('should curry a 2-argument function', function()
    local add = curry(two_args_func)
    assert.are.equal(add(1)(2), 3)
  end)

end)

describe('utils.swap', function()
  it('should work', function()
    local swapped_concat = utils.swap(function(a, b)
      return a .. b
    end)
    assert.are.equal(swapped_concat("Hello", "World"), "WorldHello")
  end)
end)
