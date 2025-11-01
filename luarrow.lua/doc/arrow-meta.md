# luarrow.arrow.meta - Metatable-based Function Application

## Overview

`luarrow.arrow.meta` provides an alternative approach to eliminating function wrapping by using `debug.setmetatable` to modify the global number metatable. This allows natural operator-based function application directly on numbers.

## ⚠️ Warning

**This module uses `debug.setmetatable` which affects ALL numbers globally in your Lua environment.**

- May have unexpected side effects
- Not recommended for production use without careful consideration
- The `debug` library is generally not recommended for regular use
- Use only when you understand the implications

## API

### `arrow(value)` or `meta(value)`

Wraps a number value to enable operator-based function application.

```lua
local meta = require('luarrow.arrow.meta')
local result = meta(42)
```

### Operator: `*`

Apply a function to a wrapped number using the multiplication operator.

```lua
local result = meta(42) * (function(x) return x * 2 end)
-- result = 84 (type: number)
```

### `arrow.unwrap(value)`

Removes the wrapped state from a value (doesn't remove the global metatable, just marks the value as no longer wrapped).

```lua
local val = meta(42)
meta.unwrap(val)
```

### `arrow.is_wrapped(value)`

Check if a value is currently wrapped.

```lua
local val = meta(42)
print(meta.is_wrapped(val))  -- true
meta.unwrap(val)
print(meta.is_wrapped(val))  -- false
```

### `arrow.reset()`

Reset the number metatable to its original state. **Warning: affects all numbers globally.**

```lua
meta.reset()
```

## Usage Examples

### Basic Usage

```lua
local meta = require('luarrow.arrow.meta')

-- Wrap a number and apply a function
local result = meta(42) * (function(x) return x * 2 end)
print(result)  -- 84
print(type(result))  -- number
```

### Chaining Functions

```lua
local f = function(x) return x + 1 end
local g = function(x) return x * 10 end

local result = meta(42) * f * g
print(result)  -- 430
```

### Using with print

```lua
local result = meta(42) * (function(x) return x * 2 end)
local _ = result * print  -- Prints: 84
```

### Unwrapping

```lua
local val = meta(100)
print(meta.is_wrapped(val))  -- true
meta.unwrap(val)
print(meta.is_wrapped(val))  -- false
```

## Comparison with arrow.wrap()

| Feature | arrow.wrap() | arrow.meta |
|---------|-------------|------------|
| Global Effects | None | ⚠️ Modifies all numbers |
| Return Type | Table wrapper | Actual number |
| Operator | `%` (chain), `^` (unwrap) | `*` (apply) |
| Safety | ✓ Safe | ⚠️ Use with caution |
| Value Access | `.value` property | Direct |
| Use Case | Production code | Experimental/specific scenarios |

## When to Use

**Use `arrow.wrap()`** (recommended):
- Production code
- When you want to avoid global modifications
- When you need a safe, predictable API

**Use `arrow.meta()`**:
- Experimental projects
- When you need the most natural syntax
- When you understand and accept the global metatable implications
- In isolated environments where global effects are acceptable

## Implementation Details

The module uses `debug.setmetatable(0, metatable)` to set a metatable on all number values. This metatable intercepts the `*` operator and checks if it's being used with a function. If so, it applies the function; otherwise, it performs normal multiplication.

A weak table is used to track which numbers are "wrapped" to avoid memory leaks.

## License

Same as luarrow - MIT
