vim.o.termguicolors = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = '␣', precedes = "<", extends = ">" }

vim.o.number = true
vim.o.relativenumber = true

vim.o.wrap = true
vim.o.showbreak = "↪ "

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

vim.o.ignorecase = true
vim.o.smartcase = true
-- :set wildoptions=pum

vim.o.winborder = "rounded"
vim.o.cursorline = true
vim.o.background = "dark"

vim.diagnostic.config({ virtual_text = true })


-- disable netrw
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
