local M = {}

---Holds multiple values for use in arrow and fun pipelines without needing `:apply()`.
---
---Example (arrow style):
---```lua
---local result = let(10, 20)
---  % arrow(function(x, y) return x * 10, y * 20 end)
---  ^ arrow(function(x, y) return tostring(x + y) end)
---```
---
---Example (fun style):
---```lua
---local result = fun(g) * fun(f) % let(10, 20)
---```
---
---@class Let : { _values: unknown[] }
local Let = {}
Let.__index = Let

---@private
Let.__is_luarrow_let = true

---Exposes for users
---@alias luarrow.Let Let

---Handles `let(x, y, ...) % arrow_or_fun`, applying all stored values.
---@param f Arrow|Fun
Let.__mod = function(self, f)
  return f:apply(table.unpack(self._values))
end

---@param ... unknown
---@return Let
function Let.new(...)
  ---@type Let
  local self = setmetatable({}, Let)
  self._values = { ... }
  return self
end

M.let = Let.new
M.Let = Let

return M
