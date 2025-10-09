local identity_module = require('luarrow.monad.identity')
local maybe_module = require('luarrow.monad.maybe')
local either_module = require('luarrow.monad.either')

local M = {}

-- Export Identity monad
M.identity = identity_module.identity
M.Identity = identity_module.Identity

-- Export Maybe monad
M.just = maybe_module.just
M.nothing = maybe_module.nothing
M.Maybe = maybe_module.Maybe

-- Export Either monad
M.right = either_module.right
M.left = either_module.left
M.Either = either_module.Either

-- Keep 'pure' as an alias for 'identity' for backward compatibility
M.pure = identity_module.identity
M.Pure = identity_module.Identity

return M
