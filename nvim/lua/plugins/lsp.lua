vim.pack.add {
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
}

require("mason").setup()

vim.lsp.enable({ "lua_ls", "clangd" })

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
