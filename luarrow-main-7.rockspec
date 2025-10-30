package = 'luarrow'
version = 'main-7'
source = {
   url = 'git+https://github.com/aiya000/luarrow.lua',
   tag = 'main',
}
description = {
   summary = 'Haskell-style function composition and application for Lua',
   detailed = [[
      luarrow.lua brings the elegance of Haskell's function composition to Lua
      with beautiful operator overloading. Write `fun(f) * fun(g) % x` instead
      of `f(g(x))` and make your functional pipelines readable and maintainable.

      Features:
      - Haskell-inspired syntax with * for composition and % for application
      - Zero dependencies - pure Lua implementation
      - Minimal overhead with simple table wrapping
   ]],
   homepage = 'https://github.com/aiya000/luarrow.lua',
   license = 'MIT',
}
dependencies = {
   'lua >= 5.1',
}
build = {
   type = 'builtin',
   modules = {
      luarrow = 'luarrow.lua/src/luarrow.lua',
      ['luarrow.fun'] = 'luarrow.lua/src/luarrow/fun.lua',
      ['luarrow.arrow'] = 'luarrow.lua/src/luarrow/arrow.lua',
   },
   copy_directories = {
      'luarrow.lua/doc',
   },
}
