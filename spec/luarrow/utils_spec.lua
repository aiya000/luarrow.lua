local utils = require('luarrow.utils')
local curry = utils.curry

describe('utils.curry', function()
  it('should curry a function with 2 arguments', function()
    local add = curry(function(a, b)
      return a + b
    end)
    
    local result = add(1)(2)
    assert.are.equal(3, result)
  end)

  it('should curry a function with 3 arguments', function()
    local add3 = curry(function(a, b, c)
      return a + b + c
    end)
    
    local result = add3(1)(2)(3)
    assert.are.equal(6, result)
  end)

  it('should allow partial application', function()
    local add = curry(function(a, b)
      return a + b
    end)
    
    local add10 = add(10)
    local result = add10(5)
    assert.are.equal(15, result)
  end)

  it('should allow multiple arguments at once', function()
    local add3 = curry(function(a, b, c)
      return a + b + c
    end)
    
    local result = add3(1, 2)(3)
    assert.are.equal(6, result)
  end)

  it('should allow all arguments at once', function()
    local add3 = curry(function(a, b, c)
      return a + b + c
    end)
    
    local result = add3(1, 2, 3)
    assert.are.equal(6, result)
  end)

  it('should work with explicit arity', function()
    -- For variadic functions, we need to specify arity
    local multiply = curry(function(...)
      local args = {...}
      local result = 1
      for _, v in ipairs(args) do
        result = result * v
      end
      return result
    end, 3)
    
    local result = multiply(2)(3)(4)
    assert.are.equal(24, result)
  end)

  it('should create specialized functions through partial application', function()
    local multiply = curry(function(a, b)
      return a * b
    end)
    
    local double = multiply(2)
    local triple = multiply(3)
    
    assert.are.equal(10, double(5))
    assert.are.equal(15, triple(5))
  end)

  it('should work with different data types', function()
    local concat = curry(function(a, b, c)
      return a .. b .. c
    end)
    
    local result = concat("Hello")(" ")("World")
    assert.are.equal("Hello World", result)
  end)
end)
