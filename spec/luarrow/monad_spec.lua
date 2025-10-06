local pure = require('luarrow.monad').pure

local function f(x)
  return x + 1
end

local function g(x)
  return x * 10
end

local function h(x)
  return x - 2
end

describe('pure', function()
  it('`pure(f) * pure(g) % x` should apply composed functions to x', function()
    local actual = pure(f) * pure(g) % 42
    local expected = f(g(42))
    assert.are.equal(actual, expected)
  end)

  it('should support composition of 3 or more functions', function()
    local actual3 = pure(f) * pure(g) * pure(h) % 42
    local expected3 = f(g(h(42)))
    assert.are.equal(actual3, expected3)
  end)

  it('method style should be usable and behave the same as operator style', function()
    local actual = pure(f):fmap(pure(g)):apply(42)
    local expected = pure(f) * pure(g) % 42
    assert.are.equal(actual, expected)
  end)

  it('pure should wrap values correctly', function()
    local wrapped = pure(10)
    assert.are.equal(wrapped.value, 10)
  end)

  it('pure with function should work correctly', function()
    local add_five = function(x)
      return x + 5
    end
    local wrapped_fn = pure(add_five)
    local result = wrapped_fn % 10
    assert.are.equal(result, 15)
  end)
end)
