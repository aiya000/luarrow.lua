local meta = require('luarrow.arrow.meta')

describe('luarrow.arrow.meta', function()
	-- Clean up after each test to avoid side effects
	after_each(function()
		meta.reset()
	end)

	it('should wrap a number value', function()
		local result = meta(42)
		assert.are.equal(result, 42)
		assert.are.equal(type(result), 'number')
	end)

	it('should allow applying a function with * operator', function()
		local result = meta(42) * (function(x)
			return x * 2
		end)
		assert.are.equal(result, 84)
		assert.are.equal(type(result), 'number')
	end)

	it('should chain multiple function applications', function()
		local result = meta(42) * (function(x)
			return x * 2
		end) * (function(x)
			return x + 1
		end)
		assert.are.equal(result, 85)
	end)

	it('should work with the example from the issue', function()
		local result = meta(42) * (function(x)
			return x * 2
		end)
		assert.are.equal(type(result), 'number')
		assert.are.equal(result, 84)
	end)

	it('should mark wrapped values', function()
		local result = meta(42)
		assert.is_true(meta.is_wrapped(result))
	end)

	it('should unwrap values', function()
		local result = meta(42)
		assert.is_true(meta.is_wrapped(result))
		meta.unwrap(result)
		assert.is_false(meta.is_wrapped(result))
	end)

	it('should work with function definitions', function()
		local f = function(x)
			return x + 1
		end
		local g = function(x)
			return x * 10
		end
		local h = function(x)
			return x - 2
		end

		local result = meta(42) * f * g * h
		assert.are.equal(result, h(g(f(42))))
	end)

	it('should use arrow() function directly', function()
		local result = meta.arrow(42) * (function(x)
			return x + 1
		end)
		assert.are.equal(result, 43)
	end)
end)
