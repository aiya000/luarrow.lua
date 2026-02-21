local fun = require('luarrow.fun').fun

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

describe('fun with multiple values', function()
  it('`(a, a) -> Sometype` and `a -> (a, a)` should be composable', function()
    assert.are.equal(15, (fun(add) * fun(split)) % 5)
  end)

  it('should work with method-style apply for multiple arguments', function()
    assert.are.equal(6, fun(sum):apply(1, 2, 3))
  end)

  it('`a -> Sometype` and `(a, a) -> a` should be composable', function()
    assert.are.equal(15, (fun(split) * fun(add)):apply(10, 5))
  end)

  it('returns all multiple values when using `:apply()`', function()
    local r1, r2, r3 = (fun(triple) * fun(split)):apply(5)
    assert.are.equal(5, r1)
    assert.are.equal(10, r2)
    assert.are.equal(50, r3)
  end)

  it("returns only the first value when using `%` due to Lua's operator limitations", function()
    -- The `%` operator only captures the first return value
    ---@diagnostic disable-next-line: unbalanced-assignments
    local r1, r2, r3 = fun(triple) * fun(split) % 5
    assert.are.equal(5, r1)
    assert.are.equal(nil, r2)
    assert.are.equal(nil, r3)

    -- To capture all values, prepend `fun(table.pack)` at the front of the chain to collect them into a table
    local result = fun(table.pack) * fun(triple) * fun(split) % 5
    assert.are.equal(5, result[1])
    assert.are.equal(10, result[2])
    assert.are.equal(50, result[3])
  end)

  it('should support varargs in composition', function()
    assert.are.equal(5, (fun(count) * fun(table.pack)):apply(1, 2, 3, 4, 5))
  end)

  it('should handle functions that return different numbers of values', function()
    local function one_to_two(x)
      return x, x + 1 -- `x + 1` is ignored
    end

    local function one_to_three(x)
      return x, x * 2, x * 3
    end

    local r1, r2, r3 = (fun(one_to_three) * fun(one_to_two)):apply(10)
    assert.are.equal(10, r1)
    assert.are.equal(20, r2)
    assert.are.equal(30, r3)
  end)
end)
