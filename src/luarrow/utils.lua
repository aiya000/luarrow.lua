local M = {}

-- Compatibility for Lua 5.1 and 5.2+
local unpack = unpack or table.unpack

---Transforms a function that takes multiple arguments into a curried version
---that returns a series of functions, each taking a single argument.
---
---Example:
---```lua
---local add = curry(function(a, b, c)
---  return a + b + c
---end)
---
---add(1)(2)(3) -- returns 6
---add(1, 2)(3) -- also returns 6
---add(1, 2, 3) -- also returns 6
---```
---
---@param func function The function to curry
---@param arity number|nil Optional number of arguments (defaults to function arity)
---@return function The curried function
function M.curry(func, arity)
  -- Get the arity (number of parameters) if not provided
  arity = arity or debug.getinfo(func, 'u').nparams
  
  ---@param accumulated table Arguments accumulated so far
  ---@return function
  local function curried(accumulated)
    return function(...)
      local args = {...}
      local new_accumulated = {}
      
      -- Copy accumulated arguments
      for i, v in ipairs(accumulated) do
        new_accumulated[i] = v
      end
      
      -- Add new arguments
      for i, v in ipairs(args) do
        table.insert(new_accumulated, v)
      end
      
      -- If we have enough arguments, call the original function
      if #new_accumulated >= arity then
        return func(unpack(new_accumulated))
      else
        -- Otherwise, return a new curried function
        return curried(new_accumulated)
      end
    end
  end
  
  return curried({})
end

return M
