local M = {}

---**Metatable-based arrow operations**!
---
---WARNING: This module uses debug.setmetatable to modify the metatable
---of all number values globally. This allows using arithmetic operators
---on numbers with functions, but may have unexpected side effects.
---Use with caution and only when you understand the implications.
---
---Example usage:
---```lua
---local arrow = require('luarrow.arrow.meta')
---local result = arrow(42) * (function(x) return x * 2 end)
---print(type(result)) -- number
---local _ = result * print -- 84
---arrow.unwrap(result) -- removes the debug metatable
---```

-- Store the original number metatable (if any)
local original_number_mt = debug.getmetatable(0)

-- Flag to track if we've initialized the metatable
local initialized = false

-- Metatable for wrapped numbers
local NumberMeta = {
	-- Store wrapped state in a weak table to avoid memory leaks
	_wrapped = setmetatable({}, { __mode = 'k' }),
}

---Apply a function to a number using the * operator
---@param num number
---@param func function
---@return number
NumberMeta.__mul = function(num, func)
	-- Check if this is a wrapped number being multiplied by a function
	if type(num) == 'number' and type(func) == 'function' then
		local result = func(num)
		-- Mark the result as wrapped if it's a number
		if type(result) == 'number' then
			NumberMeta._wrapped[result] = true
		end
		return result
		-- Check if this is a function being multiplied by a wrapped number
	elseif type(num) == 'function' and type(func) == 'number' then
		local result = num(func)
		if type(result) == 'number' then
			NumberMeta._wrapped[result] = true
		end
		return result
		-- Otherwise, fall back to original multiplication
	elseif original_number_mt and original_number_mt.__mul then
		return original_number_mt.__mul(num, func)
	else
		-- Normal numeric multiplication
		return num * func
	end
end

-- Preserve other metamethods from original metatable if they exist
if original_number_mt then
	for k, v in pairs(original_number_mt) do
		if k ~= '__mul' and not NumberMeta[k] then
			NumberMeta[k] = v
		end
	end
end

---Initialize the global number metatable
---This is called automatically when the module is loaded
local function init()
	if not initialized then
		debug.setmetatable(0, NumberMeta)
		initialized = true
	end
end

---Wrap a number value to enable operator-based function application
---@generic T
---@param value T
---@return T
function M.arrow(value)
	init()
	if type(value) == 'number' then
		NumberMeta._wrapped[value] = true
	end
	return value
end

-- Make M callable as a shorthand for M.arrow
setmetatable(M, {
	__call = function(_, value)
		return M.arrow(value)
	end,
})

---Unwrap a value by removing it from the wrapped set
---This doesn't actually remove the metatable (which is global),
---but marks the value as no longer wrapped
---@generic T
---@param value T
---@return T
function M.unwrap(value)
	if type(value) == 'number' then
		NumberMeta._wrapped[value] = nil
	end
	return value
end

---Check if a value is currently wrapped
---@param value any
---@return boolean
function M.is_wrapped(value)
	if type(value) == 'number' then
		return NumberMeta._wrapped[value] == true
	end
	return false
end

---Reset the number metatable to its original state
---WARNING: This affects all numbers globally
function M.reset()
	if initialized then
		debug.setmetatable(0, original_number_mt)
		NumberMeta._wrapped = setmetatable({}, { __mode = 'k' })
		initialized = false
	end
end

return M
