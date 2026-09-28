local prettier = { 'prettierd', 'prettier', stop_after_first = true }

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<M-S-f>',
      function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
      mode = { 'n', 'v' },
      desc = 'Format document or selection',
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_fix', 'ruff_organize_imports', 'ruff_format' },
      c = { 'clang-format' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      go = { 'goimports', 'gofmt' },
      javascript = prettier,
      json = prettier,
      jsonc = prettier,
      html = prettier,
      css = prettier,
      markdown = prettier,
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
      if vim.tbl_contains({ 'python', 'c', 'markdown' }, vim.bo[bufnr].filetype) then return end
      return { timeout_ms = 500, lsp_format = 'fallback' }
    end,
  },
  init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
}
