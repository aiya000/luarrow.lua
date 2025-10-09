local fun_module = require('luarrow.fun')
local arrow_module = require('luarrow.arrow')
local monad_module = require('luarrow.monad')

return {
  fun = fun_module.fun,
  Fun = fun_module.Fun,
  arrow = arrow_module.arrow,
  Arrow = arrow_module.Arrow,
  -- Identity monad (and backward compatible 'pure')
  pure = monad_module.pure,
  Pure = monad_module.Pure,
  identity = monad_module.identity,
  Identity = monad_module.Identity,
  -- Maybe monad
  just = monad_module.just,
  nothing = monad_module.nothing,
  Maybe = monad_module.Maybe,
  -- Either monad
  right = monad_module.right,
  left = monad_module.left,
  Either = monad_module.Either,
}
