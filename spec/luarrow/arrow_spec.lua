local arrow = require('luarrow.arrow').arrow

local function f(x)
  return x + 1
end

local function g(x)
  return x * 10
end

local function h(x)
  return x - 2
end

local function k(x)
  return x * 100
end

describe('arrow', function()
  it('`x % arrow(f) ^ arrow(g)` should be the same as `g(f(x))`', function()
    local actual = 42 % arrow(f) ^ arrow(g)
    local expected = g(f(42))
    assert.are.equal(actual, expected)
  end)

  it('the operator style should be able to compose 3 or more functions', function()
    local actual3 = 42 % arrow(f) ^ arrow(g) ^ arrow(h)
    local expected3 = h(g(f(42)))
    assert.are.equal(actual3, expected3)

    local actual4 = 42 % arrow(f) ^ arrow(g) ^ arrow(h) ^ arrow(k)
    local expected4 = k(h(g(f(42))))
    assert.are.equal(actual4, expected4)
  end)

  it('method style should be usable and behave the same as operator style', function()
    local actual = arrow(f):compose_to(arrow(g)):apply(42)
    local expected = 42 % arrow(f) ^ arrow(g)
    assert.are.equal(actual, expected)
  end)

  it('`arrow(f) % x` should raise an error (reversed order is not allowed)', function()
    assert.has_error(function()
      local _ = arrow(f) % 42
    end)
  end)
end)
