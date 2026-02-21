# AGENTS.md

This file contains coding style guidelines for AI agents working on this project.

## Lua Style

### Nil Checks

When checking whether a value is nil or not nil (not expecting falsy values), use explicit nil comparisons:

```lua
-- ✅ Good
if x ~= nil then ... end
if x == nil then ... end

-- ❌ Bad (avoid truthy/falsy checks when only nil matters)
if x then ... end
if not x then ... end
```
