local arrow = require('luarrow.arrow').arrow
local fun = require('luarrow.fun').fun
local let = require('luarrow.let').let

describe('let', function()
  it('`let(x, y) % arrow(f)` should pass all values to f', function()
    local result = let(10, 20) % arrow(function(x, y)
      return x + y
    end)
    assert.are.equal(30, result)
  end)

  it('`let(x, y) % arrow(f) ^ arrow(g)` should compose the full pipeline', function()
    local result = let(10, 20)
      % arrow(function(x, y)
          return x * 10, y * 20
        end)
        ^ arrow(function(x, y)
          return tostring(x + y)
        end)
    assert.are.equal('500', result)
  end)

  it('`fun(g) * fun(f) % let(x, y)` should pass all values to f', function()
    local result = fun(function(x, y)
      return x + y
    end) % let(10, 20)
    assert.are.equal(30, result)
  end)

  it('`let(x, y) % (fun(g) * fun(f))` should work with explicit parentheses', function()
    local result = let(10, 20)
      % (
        fun(function(x, y)
          return tostring(x + y)
        end) * fun(function(x, y)
          return x * 10, y * 20
        end)
      )
    assert.are.equal('500', result)
  end)

  it('should support a single value', function()
    local result = let(42) % arrow(function(x)
      return x * 2
    end)
    assert.are.equal(84, result)
  end)

  it('should support three or more values', function()
    local result = let(1, 2, 3) % arrow(function(a, b, c)
      return a + b + c
    end)
    assert.are.equal(6, result)
  end)
end)
