vim.pack.add({
  'https://github.com/stevearc/conform.nvim',
}, { confirm = false })

do -- format
  local prettier = { 'prettierd', 'prettier', stop_after_first = true }
  require('conform').setup({
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_fix', 'ruff_organize_imports', 'ruff_format' },
      c = { 'clang-formart' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      go = { 'goimports', 'gofmt' },

      javascript = prettier,
      json = prettier,
      jsonc = prettier,
      html = prettier,
      css = prettier,
      -- markdown = prettier,
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
      local disable_autoformat_filetype = { 'python', 'c' }
      for _, ft in ipairs(disable_autoformat_filetype) do
        if vim.bo.filetype == ft then return end
      end
      return { timeout_ms = 500, lsp_format = 'fallback' }
    end,
  })

  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
end
