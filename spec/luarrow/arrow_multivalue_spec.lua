local arrow = require('luarrow.arrow').arrow

describe('arrow with multiple values', function()
  it('should support composition where intermediate functions return multiple values', function()
    local function split(x)
      return x, x * 2
    end

    local function add_both(x, y)
      return x + y
    end

    local composed = arrow(split) ^ arrow(add_both)
    local result = composed:apply(5)
    assert.are.equal(15, result)
  end)

  it('should work with % operator for functions returning multiple intermediate values', function()
    local function split(x)
      return x, x * 2
    end

    local function add_both(x, y)
      return x + y
    end

    local composed = arrow(split) ^ arrow(add_both)
    local result = 5 % composed
    assert.are.equal(15, result)
  end)

  it('should propagate multiple values through composition chains', function()
    local function split(x)
      return x, x * 2
    end

    local function triple(x, y)
      return x, y, x * y
    end

    local composed = arrow(split) ^ arrow(triple)
    local r1, r2, r3 = composed:apply(5)
    assert.are.equal(5, r1)
    assert.are.equal(10, r2)
    assert.are.equal(50, r3)
  end)

  it('should work with method-style apply for multiple arguments', function()
    local function sum(a, b, c)
      return a + b + c
    end

    local result = arrow(sum):apply(1, 2, 3)
    assert.are.equal(6, result)
  end)

  it('should propagate multiple values through long composition chains', function()
    local function double_each(x, y)
      return x * 2, y * 2
    end

    local function add_both(x, y)
      return x + y
    end

    local composed = arrow(double_each) ^ arrow(add_both)
    local result = composed:apply(5, 10)
    assert.are.equal(30, result) -- (5*2) + (10*2) = 10 + 20 = 30
  end)

  it('should maintain backward compatibility with single values', function()
    local function add_one(x)
      return x + 1
    end

    local function multiply_ten(x)
      return x * 10
    end

    local result = 5 % arrow(add_one) ^ arrow(multiply_ten)
    assert.are.equal(60, result)
  end)

  it('should support varargs in composition', function()
    local function pack(...)
      local args = { ... }
      return args
    end

    local function count(t)
      return #t
    end

    local composed = arrow(pack) ^ arrow(count)
    local result = composed:apply(1, 2, 3, 4, 5)
    assert.are.equal(5, result)
  end)

  it('should handle functions that return different numbers of values', function()
    local function one_to_two(x)
      return x, x + 1
    end

    local function two_to_one(x, y)
      return x * y
    end

    local function one_to_three(x)
      return x, x * 2, x * 3
    end

    local composed = arrow(one_to_two) ^ arrow(two_to_one) ^ arrow(one_to_three)
    local r1, r2, r3 = composed:apply(3)
    assert.are.equal(12, r1) -- 3 * 4 = 12
    assert.are.equal(24, r2) -- 12 * 2 = 24
    assert.are.equal(36, r3) -- 12 * 3 = 36
  end)
end)
