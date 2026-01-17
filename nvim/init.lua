vim.g.mapleader = " "

require "config.autocmds"
require "config.keymaps"
require "config.options"

require "plugins"

vim.pack.add {
  { src = 'https://github.com/vague-theme/vague.nvim' },
  { src = 'https://github.com/echasnovski/mini.nvim',           name = 'mini.nvim' },
  { src = 'https://github.com/ibhagwan/fzf-lua' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
}

vim.cmd [[colorscheme vague]]

require('mini.icons').setup()
require('mini.files').setup({
  mappings = {
    go_in_plus = '<CR>'
  }
})
vim.keymap.set('n', '<leader>e', MiniFiles.open)

require("mason").setup()
vim.lsp.enable({ "lua_ls", "clangd" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

require("fzf-lua").setup("fzf-tmux")
vim.keymap.set('n', '<leader>f', FzfLua.global)
