do
  local nmap = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { desc = desc })
  end
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
  end
  vim.g.mapleader = ' '
  nmap('c', '"_c')

  nmap('<c-p>', '<cmd>FzfLua global<cr>')
  nmap('<leader>,', '<cmd>FzfLua buffers<cr>')
  nmap('<leader>/', '<cmd>FzfLua live_grep<cr>')

  nmap('-', function() require('yazi').yazi() end)
  nmap('H', '<cmd>bp<cr>')
  nmap('L', '<cmd>bn<cr>')
  nmap('<leader>d', '<cmd>bd<cr>')
  nmap('<c-d>', '<cmd>bd<cr>')
  map({ 'i', 'c' }, 'jk', '<esc>')

  map({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
  map({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
  map({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
  map({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
  nmap('<A-h>', '<C-w>h')
  nmap('<A-j>', '<C-w>j')
  nmap('<A-k>', '<C-w>k')
  nmap('<A-l>', '<C-w>l')
end

do
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.clipboard = 'unnamedplus'
  vim.opt.foldmethod = 'marker'
  require('vim._core.ui2').enable()
  vim.cmd('packadd! nohlsearch')
  vim.cmd('packadd! matchit')
end

do
  local lsp_servers = {
    lua_ls = {
      Lua = { workspace = { library = vim.api.nvim_get_runtime_file('lua', true) } },
    },
    clangd = {},
    rust_analyzer = {},
    gopls = {},
  }

  vim.pack.add({
    'https://github.com/neovim/nvim-lspconfig', -- default configs for lsps

    'https://github.com/mason-org/mason.nvim', -- package manager
    'https://github.com/mason-org/mason-lspconfig.nvim', -- lspconfig bridge
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim', -- auto installer
  }, { confirm = false })

  require('mason').setup()
  require('mason-lspconfig').setup()
  require('mason-tool-installer').setup({
    ensure_installed = vim.tbl_keys(lsp_servers),
  })

  for server, config in pairs(lsp_servers) do
    vim.lsp.config(server, {
      settings = config,

      on_attach = function(_, bufnr)
	-- stylua: ignore start
        vim.keymap.set( 'n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'vim.lsp.buf.code_action()' })
        -- stylua: ignore end
      end,
    })
  end
end

vim.pack.add({
  'https://github.com/mikavilpas/yazi.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  -- 'https://github.com/vague-theme/vague.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/stevearc/conform.nvim',
}, { confirm = false })

vim.cmd.colorscheme('catppuccin')
-- require('vague').setup({ italic = false })
require('yazi').setup({
  open_for_directories = true,
})

require('mini.completion').setup()
vim.keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
vim.o.completeopt = 'menuone,noselect,fuzzy'
require('mini.git').setup()
require('mini.tabline').setup()
require('mini.statusline').setup()
require('mini.diff').setup()
require('mini.basics').setup({ options = { basic = true, extra_ui = true } })
-- mini.clue {{{
local miniclue = require('mini.clue')
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = { 'n', 'x' }, keys = '<Leader>' },

    -- `[` and `]` keys
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = { 'n', 'x' }, keys = 'g' },

    -- Marks
    { mode = { 'n', 'x' }, keys = "'" },
    { mode = { 'n', 'x' }, keys = '`' },

    -- Registers
    { mode = { 'n', 'x' }, keys = '"' },
    { mode = { 'i', 'c' }, keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = { 'n', 'x' }, keys = 'z' },
  },
  window = {
    config = { width = 'auto' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})
-- }}}

do
  local prettier = { 'prettierd', 'prettier', stop_after_first = true }
  require('conform').setup({
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      go = { 'goimports', 'gofmt' },

      javascript = prettier,
      json = prettier,
      jsonc = prettier,
      html = prettier,
      css = prettier,
      markdown = prettier,
    },
  })

  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function(args) require('conform').format({ bufnr = args.buf }) end,
  })

  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
end

require('fzf-lua').setup({
  winopts = {
    fullscreen = true,
    preview = {
      layout = 'vertical',
      vertical = 'up:45%',
    },
  },
})
