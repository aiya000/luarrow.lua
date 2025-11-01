local fun = require('luarrow.fun')

local function f(x)
  return x + 1
end

local function g(x)
  return x * 10
end

local function h(x)
  return x - 2
end

describe('fun.wrap', function()
  it('should allow applying functions without wrapping them in fun()', function()
    local result = fun.wrap(42) % f
    assert.are.equal(result, f(42))
  end)

  it('should support mixed fun() wrapped and unwrapped functions', function()
    local result = fun.wrap(42) % fun.fun(f)
    assert.are.equal(result, f(42))
  end)

  it('should unwrap immediately with % operator', function()
    local result = fun.wrap(42) % f
    assert.are.equal(type(result), 'number')
    assert.are.equal(result, 43)
  end)

  it('should allow the value to be used directly without .get() method', function()
    -- This test documents that .get() is not needed
    -- The % operator already unwraps the value
    local result = fun.wrap(42) % f
    assert.are.equal(result, 43)
    -- No need for: result.get() or result:get() or result.value
  end)
end)
