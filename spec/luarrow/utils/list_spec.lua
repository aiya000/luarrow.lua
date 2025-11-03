local list = require('luarrow.utils.list')
local arrow = require('luarrow.arrow').arrow

describe('luarrow.utils.list', function()
  describe('map', function()
    it('should apply function to each element', function()
      local result = list.map({ 1, 2, 3 }, function(x)
        return x * 2
      end)
      assert.are.same({ 2, 4, 6 }, result)
    end)

    it('should work with empty list', function()
      local result = list.map({}, function(x)
        return x * 2
      end)
      assert.are.same({}, result)
    end)

    it('should work with arrow', function()
      local result = { 1, 2, 3 }
        % arrow(function(l)
          return list.map(l, function(x)
            return x + 10
          end)
        end)
      assert.are.same({ 11, 12, 13 }, result)
    end)
  end)

  describe('filter', function()
    it('should keep elements that satisfy predicate', function()
      local result = list.filter({ 1, 2, 3, 4, 5 }, function(x)
        return x % 2 == 0
      end)
      assert.are.same({ 2, 4 }, result)
    end)

    it('should work with empty list', function()
      local result = list.filter({}, function(x)
        return x % 2 == 0
      end)
      assert.are.same({}, result)
    end)

    it('should work with arrow', function()
      local result = { 11, 12, 13 }
        % arrow(function(l)
          return list.filter(l, function(x)
            return x % 2 ~= 0
          end)
        end)
      assert.are.same({ 11, 13 }, result)
    end)
  end)

  describe('flat_map / concat_map', function()
    it('should map and flatten one level', function()
      local result = list.flat_map({ 1, 2, 3 }, function(x)
        return { x, x * 2 }
      end)
      assert.are.same({ 1, 2, 2, 4, 3, 6 }, result)
    end)

    it('concat_map should be alias for flat_map', function()
      local result = list.concat_map({ 1, 2 }, function(x)
        return { x, x + 1 }
      end)
      assert.are.same({ 1, 2, 2, 3 }, result)
    end)
  end)

  describe('foldl / reduce', function()
    it('should fold left with initial value', function()
      local result = list.foldl({ 1, 2, 3, 4 }, function(acc, x)
        return acc + x
      end, 0)
      assert.are.equal(10, result)
    end)

    it('should work with strings', function()
      local result = list.foldl({ 'a', 'b', 'c' }, function(acc, x)
        return acc .. x
      end, '')
      assert.are.equal('abc', result)
    end)

    it('reduce should be alias for foldl', function()
      local result = list.reduce({ 1, 2, 3 }, function(acc, x)
        return acc * x
      end, 1)
      assert.are.equal(6, result)
    end)
  end)

  describe('foldr', function()
    it('should fold right with initial value', function()
      local result = list.foldr({ 'a', 'b', 'c' }, function(x, acc)
        return x .. acc
      end, 'd')
      assert.are.equal('abcd', result)
    end)

    it('should work with numbers', function()
      local result = list.foldr({ 1, 2, 3 }, function(x, acc)
        return x - acc
      end, 0)
      -- 1 - (2 - (3 - 0)) = 1 - (2 - 3) = 1 - (-1) = 2
      assert.are.equal(2, result)
    end)
  end)

  describe('foldl1', function()
    it('should fold left without initial value', function()
      local result = list.foldl1({ 1, 2, 3, 4 }, function(acc, x)
        return acc + x
      end)
      assert.are.equal(10, result)
    end)

    it('should throw error on empty list', function()
      assert.has_error(function()
        list.foldl1({}, function(acc, x)
          return acc + x
        end)
      end)
    end)
  end)

  describe('foldr1', function()
    it('should fold right without initial value', function()
      local result = list.foldr1({ 'a', 'b', 'c' }, function(x, acc)
        return x .. acc
      end)
      assert.are.equal('abc', result)
    end)

    it('should throw error on empty list', function()
      assert.has_error(function()
        list.foldr1({}, function(x, acc)
          return x .. acc
        end)
      end)
    end)
  end)

  describe('flatten', function()
    it('should flatten one level of nesting', function()
      local result = list.flatten({ { 1, 2 }, { 3, 4 }, { 5 } })
      assert.are.same({ 1, 2, 3, 4, 5 }, result)
    end)

    it('should work with empty sublists', function()
      local result = list.flatten({ { 1 }, {}, { 2 } })
      assert.are.same({ 1, 2 }, result)
    end)
  end)

  describe('join', function()
    it('should join strings with delimiter', function()
      local result = list.join({ 'a', 'b', 'c' }, ', ')
      assert.are.equal('a, b, c', result)
    end)

    it('should work with empty string delimiter', function()
      local result = list.join({ 'hello', 'world' }, '')
      assert.are.equal('helloworld', result)
    end)
  end)

  describe('sum', function()
    it('should sum numeric elements', function()
      local result = list.sum({ 1, 2, 3, 4, 5 })
      assert.are.equal(15, result)
    end)

    it('should return 0 for empty list', function()
      local result = list.sum({})
      assert.are.equal(0, result)
    end)
  end)

  describe('product', function()
    it('should multiply numeric elements', function()
      local result = list.product({ 2, 3, 4 })
      assert.are.equal(24, result)
    end)

    it('should return 1 for empty list', function()
      local result = list.product({})
      assert.are.equal(1, result)
    end)
  end)

  describe('length', function()
    it('should return number of elements', function()
      assert.are.equal(3, list.length({ 1, 2, 3 }))
      assert.are.equal(0, list.length({}))
    end)
  end)

  describe('is_empty', function()
    it('should return true for empty list', function()
      assert.is_true(list.is_empty({}))
    end)

    it('should return false for non-empty list', function()
      assert.is_false(list.is_empty({ 1 }))
    end)
  end)

  describe('head', function()
    it('should return first element', function()
      assert.are.equal(1, list.head({ 1, 2, 3 }))
    end)

    it('should return nil for empty list', function()
      assert.is_nil(list.head({}))
    end)
  end)

  describe('tail', function()
    it('should return list without first element', function()
      local result = list.tail({ 1, 2, 3, 4 })
      assert.are.same({ 2, 3, 4 }, result)
    end)

    it('should return empty list when given single element', function()
      local result = list.tail({ 1 })
      assert.are.same({}, result)
    end)

    it('should return empty list when given empty list', function()
      local result = list.tail({})
      assert.are.same({}, result)
    end)
  end)

  describe('last', function()
    it('should return last element', function()
      assert.are.equal(3, list.last({ 1, 2, 3 }))
    end)

    it('should return nil for empty list', function()
      assert.is_nil(list.last({}))
    end)
  end)

  describe('init', function()
    it('should return all elements except last', function()
      local result = list.init({ 1, 2, 3, 4 })
      assert.are.same({ 1, 2, 3 }, result)
    end)

    it('should return empty list when given single element', function()
      local result = list.init({ 1 })
      assert.are.same({}, result)
    end)
  end)

  describe('reverse', function()
    it('should reverse the list', function()
      local result = list.reverse({ 1, 2, 3, 4 })
      assert.are.same({ 4, 3, 2, 1 }, result)
    end)

    it('should work with empty list', function()
      local result = list.reverse({})
      assert.are.same({}, result)
    end)
  end)

  describe('maximum', function()
    it('should return largest element', function()
      assert.are.equal(5, list.maximum({ 3, 1, 5, 2, 4 }))
    end)

    it('should throw error on empty list', function()
      assert.has_error(function()
        list.maximum({})
      end)
    end)
  end)

  describe('minimum', function()
    it('should return smallest element', function()
      assert.are.equal(1, list.minimum({ 3, 1, 5, 2, 4 }))
    end)

    it('should throw error on empty list', function()
      assert.has_error(function()
        list.minimum({})
      end)
    end)
  end)

  describe('sort', function()
    it('should sort numbers', function()
      local result = list.sort({ 3, 1, 4, 1, 5, 9, 2, 6 })
      assert.are.same({ 1, 1, 2, 3, 4, 5, 6, 9 }, result)
    end)

    it('should sort strings', function()
      local result = list.sort({ 'c', 'a', 'b' })
      assert.are.same({ 'a', 'b', 'c' }, result)
    end)

    it('should not modify original list', function()
      local original = { 3, 1, 2 }
      local result = list.sort(original)
      assert.are.same({ 3, 1, 2 }, original)
      assert.are.same({ 1, 2, 3 }, result)
    end)
  end)

  describe('sort_by / sort_with', function()
    it('should sort by key function', function()
      local items = { { name = 'c', value = 3 }, { name = 'a', value = 1 }, { name = 'b', value = 2 } }
      local result = list.sort_by(items, function(x)
        return x.value
      end)
      assert.are.equal('a', result[1].name)
      assert.are.equal('b', result[2].name)
      assert.are.equal('c', result[3].name)
    end)

    it('should sort with comparator function', function()
      local result = list.sort_by({ 3, 1, 2 }, function(a, b)
        return a > b
      end)
      assert.are.same({ 3, 2, 1 }, result)
    end)

    it('sort_with should be alias for sort_by', function()
      local result = list.sort_with({ 3, 1, 2 }, function(a, b)
        return a < b
      end)
      assert.are.same({ 1, 2, 3 }, result)
    end)
  end)

  describe('unique', function()
    it('should remove duplicates', function()
      local result = list.unique({ 1, 2, 2, 3, 1, 4, 3 })
      assert.are.same({ 1, 2, 3, 4 }, result)
    end)

    it('should keep first occurrence', function()
      local result = list.unique({ 'a', 'b', 'a', 'c', 'b' })
      assert.are.same({ 'a', 'b', 'c' }, result)
    end)
  end)

  describe('group_by', function()
    it('should group by key function', function()
      local items = { 1, 2, 3, 4, 5, 6 }
      local result = list.group_by(items, function(x)
        return x % 2
      end)
      assert.are.same({ 2, 4, 6 }, result[0])
      assert.are.same({ 1, 3, 5 }, result[1])
    end)

    it('should work with string keys', function()
      local items = { { type = 'a', val = 1 }, { type = 'b', val = 2 }, { type = 'a', val = 3 } }
      local result = list.group_by(items, function(x)
        return x.type
      end)
      assert.are.equal(2, #result['a'])
      assert.are.equal(1, #result['b'])
    end)
  end)

  describe('find', function()
    it('should find first element satisfying predicate', function()
      local result = list.find({ 1, 2, 3, 4, 5 }, function(x)
        return x > 3
      end)
      assert.are.equal(4, result)
    end)

    it('should return nil if no element satisfies predicate', function()
      local result = list.find({ 1, 2, 3 }, function(x)
        return x > 10
      end)
      assert.is_nil(result)
    end)

    it('should work with arrow', function()
      local result = { 11, 12, 13 }
        % arrow(function(l)
          return list.find(l, function(x)
            return x > 10
          end)
        end)
      assert.are.equal(11, result)
    end)
  end)

  describe('pipeline example from issue', function()
    it('should work with map, filter, and find', function()
      local result = { 1, 2, 3 }
        % arrow(function(l)
            return list.map(l, function(x)
              return x + 10
            end)
          end)
          ^ arrow(function(l)
            return list.filter(l, function(x)
              return x % 2 ~= 0
            end)
          end)
          ^ arrow(function(l)
            return list.find(l, function(x)
              return x > 10
            end)
          end)
      assert.are.equal(11, result)
    end)
  end)
end)
