vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
})

require("mason").setup()

vim.lsp.enable({ "lua_ls", "clangd", "vtsls", "superhtml" })
vim.lsp.inlay_hint.enable(true)

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
