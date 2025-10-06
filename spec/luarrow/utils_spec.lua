local utils = require('luarrow.utils')
local curry = utils.curry
local partial = utils.partial
local swap = utils.swap

describe('utils.partial', function()
  local function two_args_func(a, b)
    return a + b
  end

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

  it('should partially apply a function with 2 arguments', function()
    local add = partial(two_args_func)
    assert.are.equal(add(1)(2), 3)
  end)

  it('should partially apply a function with 3 arguments', function()
    local add = partial(three_args_func)
    assert.are.equal(add(1)(2)(3), 6)
  end)

  it('should allow partial application', function()
    local add = partial(two_args_func)
    local add10 = add(10)
    local result = add10(5)
    assert.are.equal(result, 15)
  end)

  it('should allow multiple arguments at once', function()
    local add = partial(three_args_func)
    assert.are.equal(add(1, 2)(3), 6)
  end)

  it('should allow all arguments at once', function()
    local add = partial(three_args_func)
    assert.are.equal(add(1, 2, 3), 6)
  end)

  it('should work with explicit arity', function()
    local multiply = partial(variadic_args_func, 3)
    assert.are.equal(multiply(2)(3)(4), 24)
  end)

  it('should create specialized functions through partial application', function()
    local multiply = partial(function(a, b)
      return a * b
    end)

    local double = multiply(2)
    local triple = multiply(3)

    assert.are.equal(10, double(5))
    assert.are.equal(15, triple(5))
  end)

  it('should work with different data types', function()
    local concat = partial(function(a, b, c)
      return a .. b .. c
    end)

    local result = concat("Hello")(" ")("World")
    assert.are.equal("Hello World", result)
  end)
end)

describe('utils.curry', function()
  it('should curry a function with 2 arguments (one at a time only)', function()
    local add = curry(function(a, b)
      return a + b
    end)

    local result = add(1)(2)
    assert.are.equal(3, result)
  end)

  it('should curry a function with 3 arguments (one at a time only)', function()
    local add3 = curry(function(a, b, c)
      return a + b + c
    end)

    local result = add3(1)(2)(3)
    assert.are.equal(6, result)
  end)

  it('should allow partial application (one at a time)', function()
    local add = curry(function(a, b)
      return a + b
    end)

    local add10 = add(10)
    local result = add10(5)
    assert.are.equal(15, result)
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

describe('utils.swap', function()
  it('should swap the arguments of a two-argument function', function()
    local divide = function(a, b)
      return a / b
    end

    local swapped_divide = swap(divide)

    -- Original: 10 / 2 = 5
    assert.are.equal(5, divide(10, 2))

    -- Swapped: 2 / 10 = 0.2
    assert.are.equal(0.2, swapped_divide(10, 2))
  end)

  it('should work with subtraction', function()
    local subtract = function(a, b)
      return a - b
    end

    local swapped_subtract = utils.swap(subtract)

    -- Original: 10 - 3 = 7
    assert.are.equal(7, subtract(10, 3))

    -- Swapped: 3 - 10 = -7
    assert.are.equal(-7, swapped_subtract(10, 3))
  end)

  it('should work with string concatenation', function()
    local concat = function(a, b)
      return a .. b
    end

    local swapped_concat = utils.swap(concat)

    assert.are.equal("HelloWorld", concat("Hello", "World"))
    assert.are.equal("WorldHello", swapped_concat("Hello", "World"))
  end)

  it('should work with functions that return different types', function()
    local make_pair = function(a, b)
      return {first = a, second = b}
    end

    local swapped_make_pair = utils.swap(make_pair)

    local original = make_pair("x", "y")
    assert.are.equal("x", original.first)
    assert.are.equal("y", original.second)

    local swapped = swapped_make_pair("x", "y")
    assert.are.equal("y", swapped.first)
    assert.are.equal("x", swapped.second)
  end)
end)
