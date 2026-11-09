-- 每个 server 的 vim.lsp.config 参数（会与 nvim-lspconfig 自带配置合并）
local servers = {
  lua_ls = {
    settings = {
      Lua = { workspace = { library = vim.api.nvim_get_runtime_file('lua', true) } },
    },
  },
  -- clangd 用 gcc 的 system include：允许 clangd 执行这些驱动来提取头文件搜索路径
  clangd = {
    cmd = {
      'clangd',
      '--background-index',
      '--all-scopes-completion',
      '--completion-style=detailed',
      '--header-insertion=never',
      '--function-arg-placeholders=0',
      '--pch-storage=memory',
      '--malloc-trim',
      '--query-driver=/usr/bin/*,/usr/local/bin/*',
    },
  },
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
    for server, conf in pairs(servers) do
      vim.lsp.config(server, conf)
      vim.lsp.enable(server)
    end

    -- 读代码用的键位（只在挂了 LSP 的 buffer 里生效）
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local fzf = function(picker)
          return function() require('fzf-lua')[picker]() end
        end
        local map = function(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = args.buf, desc = desc })
        end
        map('K', vim.lsp.buf.hover, 'Hover')
        map('gd', fzf('lsp_definitions'), 'Goto definition')
        map('<leader>gr', fzf('lsp_references'), 'References')
        map('<leader>gs', fzf('lsp_document_symbols'), 'Symbols in file')
        map('<leader>gw', fzf('lsp_live_workspace_symbols'), 'Symbols in workspace')
        map('<leader>gc', fzf('lsp_incoming_calls'), 'Callers of function')
        map(
          '<leader>gS',
          '<cmd>LspClangdSwitchSourceHeader<cr>',
          'Switch source/header'
        )
        map(
          '<leader>gh',
          function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
            )
          end,
          'Toggle inlay hints'
        )
      end,
    })
  end,
}
