local right = require('luarrow.monad.either').right
local left = require('luarrow.monad.either').left

describe('either monad', function()
  describe('right', function()
    it('should wrap a success value', function()
      local e = right(42)
      assert.is_true(e.is_right)
      assert.are.equal(e.value, 42)
    end)

    it('fmap should apply function to right value', function()
      local e = right(10)
      local result = e:fmap(function(x)
        return x + 5
      end)
      assert.is_true(result.is_right)
      assert.are.equal(result.value, 15)
    end)

    it('bind should apply monadic function to right value', function()
      local e = right(10)
      local result = e:bind(function(x)
        return right(x * 2)
      end)
      assert.is_true(result.is_right)
      assert.are.equal(result.value, 20)
    end)

    it('or_else should return the wrapped value', function()
      local e = right(42)
      local result = e:or_else(0)
      assert.are.equal(result, 42)
    end)

    it('is_left should return false', function()
      local e = right(42)
      assert.is_false(e:is_left())
    end)

    it('map_left should return right unchanged', function()
      local e = right(42)
      local result = e:map_left(function(err)
        return 'changed'
      end)
      assert.is_true(result.is_right)
      assert.are.equal(result.value, 42)
    end)
  end)

  describe('left', function()
    it('should represent an error', function()
      local e = left('error')
      assert.is_false(e.is_right)
      assert.are.equal(e.error, 'error')
    end)

    it('fmap should return left unchanged', function()
      local e = left('error')
      local result = e:fmap(function(x)
        return x + 5
      end)
      assert.is_false(result.is_right)
      assert.are.equal(result.error, 'error')
    end)

    it('bind should return left unchanged', function()
      local e = left('error')
      local result = e:bind(function(x)
        return right(x * 2)
      end)
      assert.is_false(result.is_right)
      assert.are.equal(result.error, 'error')
    end)

    it('or_else should return the default value', function()
      local e = left('error')
      local result = e:or_else(99)
      assert.are.equal(result, 99)
    end)

    it('is_left should return true', function()
      local e = left('error')
      assert.is_true(e:is_left())
    end)

    it('map_left should apply function to error', function()
      local e = left('error')
      local result = e:map_left(function(err)
        return err .. ' handled'
      end)
      assert.is_false(result.is_right)
      assert.are.equal(result.error, 'error handled')
    end)
  end)

  describe('chaining', function()
    it('should chain multiple operations with right', function()
      local result = right(10)
        % function(x)
          return right(x + 5)
        end
        % function(x)
          return right(x * 2)
        end
      assert.is_true(result.is_right)
      assert.are.equal(result.value, 30)
    end)

    it('should short-circuit on left', function()
      local result = right(10)
        % function(x)
          return left('error')
        end
        % function(x)
          return right(x * 2)
        end
      assert.is_false(result.is_right)
      assert.are.equal(result.error, 'error')
    end)

    it('should preserve first error in chain', function()
      local result = right(10)
        % function(x)
          return left('first error')
        end
        % function(x)
          return left('second error')
        end
      assert.is_false(result.is_right)
      assert.are.equal(result.error, 'first error')
    end)
  end)
end)
