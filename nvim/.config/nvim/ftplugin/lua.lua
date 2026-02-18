vim.treesitter.start()

vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
