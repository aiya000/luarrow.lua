local arrow = require('luarrow.arrow').arrow

---@type fun(x: integer): integer, integer
local function split(x)
  return x, x * 2
end

---@type fun(x: integer, y: integer): integer
local function add(x, y)
  return x + y
end

---@type fun(x: integer, y: integer, z: integer): integer
local function sum(a, b, c)
  return a + b + c
end

---@type fun(x: integer, y: integer): integer, integer, integer
local function triple(x, y)
  return x, y, x * y
end

---@type fun(xs: unknown[]): integer
local function count(xs)
  return #xs
end

describe('arrow with multiple values', function()
  it('`a -> (a, a)` and `(a, a) -> Sometype` should be composable', function()
    assert.are.equal(15, 5 % arrow(split) ^ arrow(add))
  end)

  it('should work with method-style apply for multiple arguments', function()
    assert.are.equal(6, arrow(sum):apply(1, 2, 3))
  end)

  it('`(a, a) -> a` and `a -> Sometype` should be composable', function()
    assert.are.equal(15, (arrow(add) ^ arrow(split)):apply(10, 5))
  end)

  it('returns all multiple values when using `:apply()`', function()
    local r1, r2, r3 = (arrow(split) ^ arrow(triple)):apply(10)
    assert.are.equal(10, r1)
    assert.are.equal(20, r2)
    assert.are.equal(200, r3)
  end)

  it('returns only the first value when using `%` due to Lua\'s operator limitations', function()
    -- The `%` operator only captures the first return value
    ---@diagnostic disable-next-line: unbalanced-assignments
    local r1, r2, r3 = 10 % arrow(split) ^ arrow(triple)
    assert.are.equal(10, r1)
    assert.are.equal(nil, r2)
    assert.are.equal(nil, r3)

    -- To capture all values, append `arrow(table.pack)` at the end of the chain to collect them into a table
    local result = 10 % arrow(split) ^ arrow(triple) ^ arrow(table.pack)
    assert.are.equal(10, result[1])
    assert.are.equal(20, result[2])
    assert.are.equal(200, result[3])
  end)

  it('should support varargs in composition', function()
    assert.are.equal(5, (arrow(table.pack) ^ arrow(count)):apply(1, 2, 3, 4, 5))
  end)

  it('should handle functions that return different numbers of values', function()
    local function one_to_two(x)
      return x, x + 1 -- `x + 1` is ignored
    end

    local function one_to_three(x)
      return x, x * 2, x * 3
    end

    local r1, r2, r3 = (arrow(one_to_two) ^ arrow(one_to_three)):apply(10)
    assert.are.equal(10, r1)
    assert.are.equal(20, r2)
    assert.are.equal(30, r3)
  end)
end)
