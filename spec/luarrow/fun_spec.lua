local fun = require('luarrow.fun').fun

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

describe('fun', function()
  it('`fun(f) * fun(g) % x` should be the same as `f(g(x))`', function()
    local actual = fun(f) * fun(g) % 42
    local expected = f(g(42))
    assert.are.equal(actual, expected)
  end)

  it('the operator style should be able to compose 3 or more functions', function()
    local actual3 = fun(f) * fun(g) * fun(h) % 42
    local expected3 = f(g(h(42)))
    assert.are.equal(actual3, expected3)

    local actual4 = fun(f) * fun(g) * fun(h) * fun(k) % 42
    local expected4 = f(g(h(k(42))))
    assert.are.equal(actual4, expected4)
  end)

  it('method style should be usable and behave the same as operator style', function()
    local actual = fun(f):compose(fun(g)):apply(42)
    local expected = fun(f) * fun(g) % 42
    assert.are.equal(actual, expected)
  end)
end)
