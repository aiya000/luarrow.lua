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
    local args = { ... }
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
    local result = concat('Hello')(' ')('World')
    assert.are.equal(result, 'Hello World')
  end)
end)

describe('utils.curry', function()
  it('should curry a 2-argument function', function()
    local add = curry(two_args_func)
    assert.are.equal(add(1)(2), 3)
  end)
end)

describe('utils.curry2', function()
  it('should curry a 2-argument function', function()
    local add = curry(two_args_func)
    assert.are.equal(add(1)(2), 3)
  end)
end)


describe('utils.curry3', function()
  it('should curry a 3-argument function', function()
    local add = utils.curry3(function(a, b, c)
      return a + b + c
    end)
    assert.are.equal(add(1)(2)(3), 6)
  end)
end)

describe('utils.curry4', function()
  it('should curry a 4-argument function', function()
    local add = utils.curry4(function(a, b, c, d)
      return a + b + c + d
    end)
    assert.are.equal(add(1)(2)(3)(4), 10)
  end)
end)

describe('utils.curry5', function()
  it('should curry a 5-argument function', function()
    local add = utils.curry5(function(a, b, c, d, e)
      return a + b + c + d + e
    end)
    assert.are.equal(add(1)(2)(3)(4)(5), 15)
  end)
end)

describe('utils.curry6', function()
  it('should curry a 6-argument function', function()
    local add = utils.curry6(function(a, b, c, d, e, f)
      return a + b + c + d + e + f
    end)
    assert.are.equal(add(1)(2)(3)(4)(5)(6), 21)
  end)
end)

describe('utils.curry7', function()
  it('should curry a 7-argument function', function()
    local add = utils.curry7(function(a, b, c, d, e, f, g)
      return a + b + c + d + e + f + g
    end)
    assert.are.equal(add(1)(2)(3)(4)(5)(6)(7), 28)
  end)
end)

describe('utils.curry8', function()
  it('should curry a 8-argument function', function()
    local add = utils.curry8(function(a, b, c, d, e, f, g, h)
      return a + b + c + d + e + f + g + h
    end)
    assert.are.equal(add(1)(2)(3)(4)(5)(6)(7)(8), 36)
  end)
end)

describe('utils.swap', function()
  it('should work', function()
    local swapped_concat = utils.swap(function(a, b)
      return a .. b
    end)
    assert.are.equal(swapped_concat('Hello', 'World'), 'WorldHello')
  end)
end)
