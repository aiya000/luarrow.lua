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

---@type fun(...: unknown[]): unknown[]
local function pack(...)
  local args = { ... }
  return args
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

  it('should can take returned multiple results', function()
    local r1, r2, r3 = 5 % arrow(split) ^ arrow(triple)
    assert.are.equal(5, r1)
    assert.are.equal(10, r2)
    assert.are.equal(50, r3)
  end)

  it('should support varargs in composition', function()
    assert.are.equal(5, (arrow(pack) ^ arrow(count)):apply(1, 2, 3, 4, 5))
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
