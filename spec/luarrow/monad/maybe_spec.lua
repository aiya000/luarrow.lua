local just = require('luarrow.monad.maybe').just
local nothing = require('luarrow.monad.maybe').nothing

describe('maybe monad', function()
  describe('just', function()
    it('should wrap a value', function()
      local m = just(42)
      assert.is_true(m.is_just)
      assert.are.equal(m.value, 42)
    end)

    it('fmap should apply function to just value', function()
      local m = just(10)
      local result = m:fmap(function(x)
        return x + 5
      end)
      assert.is_true(result.is_just)
      assert.are.equal(result.value, 15)
    end)

    it('bind should apply monadic function to just value', function()
      local m = just(10)
      local result = m:bind(function(x)
        return just(x * 2)
      end)
      assert.is_true(result.is_just)
      assert.are.equal(result.value, 20)
    end)

    it('or_else should return the wrapped value', function()
      local m = just(42)
      local result = m:or_else(0)
      assert.are.equal(result, 42)
    end)

    it('is_nothing should return false', function()
      local m = just(42)
      assert.is_false(m:is_nothing())
    end)
  end)

  describe('nothing', function()
    it('should represent absence of value', function()
      local m = nothing()
      assert.is_false(m.is_just)
    end)

    it('fmap should return nothing', function()
      local m = nothing()
      local result = m:fmap(function(x)
        return x + 5
      end)
      assert.is_false(result.is_just)
    end)

    it('bind should return nothing', function()
      local m = nothing()
      local result = m:bind(function(x)
        return just(x * 2)
      end)
      assert.is_false(result.is_just)
    end)

    it('or_else should return the default value', function()
      local m = nothing()
      local result = m:or_else(99)
      assert.are.equal(result, 99)
    end)

    it('is_nothing should return true', function()
      local m = nothing()
      assert.is_true(m:is_nothing())
    end)
  end)

  describe('chaining', function()
    it('should chain multiple operations with just', function()
      local result = just(10)
        % function(x)
          return just(x + 5)
        end
        % function(x)
          return just(x * 2)
        end
      assert.is_true(result.is_just)
      assert.are.equal(result.value, 30)
    end)

    it('should short-circuit on nothing', function()
      local result = just(10)
        % function(x)
          return nothing()
        end
        % function(x)
          return just(x * 2)
        end
      assert.is_false(result.is_just)
    end)
  end)
end)
