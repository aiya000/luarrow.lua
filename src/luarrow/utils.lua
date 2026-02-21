local M = {}

---Compatibility shim for `unpack`: uses `table.unpack` (Lua 5.2+) or falls back to the global `unpack` (Lua 5.1).
---@type fun(list: unknown[], i?: integer, j?: integer): ...
M.unpack = table.unpack or unpack

return M
