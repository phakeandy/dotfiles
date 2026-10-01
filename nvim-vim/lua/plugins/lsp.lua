local servers = {
  lua_ls = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file('lua', true) } } },
  clangd = {},
  rust_analyzer = {},
  gopls = {},
  vtsls = {},
  basedpyright = {},
  emmet_language_server = {},
}

return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { { 'mason-org/mason.nvim', opts = {} } },
  config = function()
    for server, settings in pairs(servers) do
      vim.lsp.config(server, { settings = settings })
      vim.lsp.enable(server)
    end
  end,
}
