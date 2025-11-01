local arrow = require('luarrow.arrow')

local function f(x)
  return x + 1
end

local function g(x)
  return x * 10
end

local function h(x)
  return x - 2
end

describe('arrow.wrap', function()
  it('should allow chaining functions without wrapping them in arrow()', function()
    local result = arrow.wrap(42) % f
    assert.are.equal(result.value, f(42))
  end)

  it('should support chaining multiple functions with %', function()
    local result = arrow.wrap(42) % f % g % h
    assert.are.equal(result.value, h(g(f(42))))
  end)

  it('should support mixed arrow() wrapped and unwrapped functions', function()
    local result = arrow.wrap(42) % f % arrow.arrow(g)
    assert.are.equal(result.value, g(f(42)))
  end)

  it('should unwrap with ^ operator', function()
    local result = (arrow.wrap(42) % f % g) ^ h
    assert.are.equal(result, h(g(f(42))))
  end)

  it('should support extracting value with .value property', function()
    local wrapped = arrow.wrap(42) % f % g
    assert.are.equal(wrapped.value, g(f(42)))
  end)

  it('should allow the value to be used directly without .get() method', function()
    -- This test documents that .get() is not needed
    -- because .value provides the same functionality
    local result = arrow.wrap(42) % f
    assert.are.equal(result.value, 43)
    -- No need for: result.get() or result:get()
  end)
end)
