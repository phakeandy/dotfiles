vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Clear highlights on search when pressing <Esc> in normal mode

vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('n', '<leader>w', ':w<CR>')
vim.keymap.set('n', '<leader>q', ':q<CR>')
vim.keymap.set('n', '<leader><leader>', ':buffers<CR>:b')
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"+d')
vim.keymap.set('n', '<leader>d', '"+d')
vim.keymap.set('n', '<leader>p', '"+p')
vim.keymap.set({ 'n', 'v' }, 'y', '"+y', { noremap = true, silent = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.pack.add({
    { src = 'https://github.com/folke/tokyonight.nvim' },
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/ibhagwan/fzf-lua' },
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})

require("oil").setup()
vim.keymap.set('n', '<leader>e', ':Oil<CR>')

require("mason").setup()
vim.lsp.enable({ "lua_ls" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

require("fzf-lua").setup("fzf-tmux")
vim.keymap.set('n', '<leader>f', FzfLua.global)


vim.cmd [[
  set list listchars=tab:»\ ,trail:·,precedes:<,extends:> " set list 可以显示 listchars (see :help listchars)
  set showbreak=↪\  " set wrap 后, line break 显示的图标
  set cursorline " 光标所在的当前行高亮
  set wrap
  set cursorline " 光标所在的当前行高亮
  set number " Show current line number
  set relativenumber " Show relative line numbers
  set background=dark
  set expandtab
  set shiftwidth=4
  set tabstop=4
  set softtabstop=4
]]

-- disable netrw
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- vim: ts=2 sts=2 sw=2 et
