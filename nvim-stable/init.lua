local nmap = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end
local map = vim.keymap.set
local create_autocmd = vim.api.nvim_create_autocmd

do
  vim.g.mapleader = ' '
  vim.g.maplocalleader = '\\'
  nmap('c', '"_c')
  -- nmap('-', function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end)
  nmap('-', '<cmd>Oil<cr>')

  local nmap_zz = function(lhs) vim.keymap.set('n', lhs, lhs .. 'zz') end

  nmap_zz('<c-d>')
  nmap_zz('<c-u>')
  nmap_zz('n')
  nmap_zz('N')

  -- flash
  map({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end)

  nmap('<leader>d', '<cmd>bd<cr>')
  nmap('<leader>b', ':b')

  map({ 'i', 'c' }, 'jk', '<esc>')
  map('t', '<esc>', '<C-\\><C-n>')

  -- Window Management {{{
  -- map({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
  -- map({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
  -- map({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
  -- map({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
  nmap('<M-h>', '<C-w>h')
  nmap('<M-j>', '<C-w>j')
  nmap('<M-k>', '<C-w>k')
  nmap('<M-l>', '<C-w>l')
  nmap('<M-o>', '<C-w>w')
  nmap('<M-left>', ':vertical resize -5<CR>')
  nmap('<M-right>', ':vertical resize +5<CR>')
  nmap('<M-up>', ':resize +5<CR>')
  nmap('<M-down>', ':resize -5<CR>')
  -- }}}
end

do
  vim.o.number = true
  -- vim.o.relativenumber = true
  vim.o.clipboard = 'unnamedplus'
  vim.o.smartcase = true
  vim.o.foldmethod = 'marker'
  vim.o.cursorline = true
  vim.opt.cmdheight = 0
  vim.opt.laststatus = 3 -- Global Statusline
  vim.o.list = false
  vim.o.wrap = true
  vim.o.exrc = true

  vim.o.smarttab = true
  vim.o.smartindent = true

  vim.o.list = true
  vim.opt.listchars =
    { tab = '» ', trail = '·', nbsp = '␣', precedes = '<', extends = '>' }

  vim.diagnostic.config({
    underline = false,
    virtual_text = false,
  })

  require('vim._core.ui2').enable()
  vim.cmd('packadd! nohlsearch')
  vim.cmd('packadd! matchit')
  vim.opt.path:append('**') -- set for :find
  vim.o.wildignore = '*/node_modules/*,*/.git/*,*/.svn/*'

  create_autocmd({ 'TextYankPost' }, {
    callback = function() vim.hl.on_yank({ higroup = 'Visual', timeout = 300 }) end,
  })

  -- Make backgroud dark
  vim.api.nvim_set_hl(
    0,
    'Normal',
    { fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg, bg = 'black' }
  )

  -- disable netrw
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_netrw = 1
end

do
  local lsp_servers = {
    lua_ls = {
      Lua = { workspace = { library = vim.api.nvim_get_runtime_file('lua', true) } },
    },
    clangd = {},
    rust_analyzer = {},
    gopls = {},
    vtsls = {},
    pylsp = {},
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
        vim.o.signcolumn = 'yes'
        -- stylua: ignore start
        map('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'vim.lsp.buf.code_action()' })
        -- stylua: ignore end
      end,
    })
  end
end

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/Exafunction/windsurf.nvim',
  'https://github.com/tpope/vim-fugitive',

  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/rafamadriz/friendly-snippets',

  'https://github.com/milanglacier/minuet-ai.nvim',
  'https://github.com/stevearc/oil.nvim',

  'https://github.com/lervag/vimtex',

  -- Improve editer experience plugins
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/keaising/im-select.nvim',
  'https://github.com/folke/flash.nvim',
}, { confirm = false })

require('im_select').setup()
require('guess-indent').setup()

do
  vim.o.completeopt = 'menuone,noselect,fuzzy'
  vim.pack.add({
    {
      src = 'https://github.com/Saghen/blink.cmp',
      version = vim.version.range('1.*'),
    },
  })

  require('blink.cmp').setup()
end

require('mini.git').setup()
require('mini.statusline').setup()
require('mini.align').setup()
require('mini.icons').setup()
require('mini.diff').setup()
require('mini.files').setup({
  mappings = {
    go_in_plus = '<cr>',
  },
})
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

-- Formater {{{
local prettier = { 'prettierd', 'prettier', stop_after_first = true }
require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_organize_imports', 'ruff_format' },
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
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
-- }}}

-- Telescope {{{
vim.pack.add({
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',

  -- needs run `cd /home/phakeandy/.local/share/nvim/site/pack/core/opt/telescope-fzf-native.nvim/ && make`
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
}, { confirm = false })

require('telescope').setup({
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown({}) },
  },
})
require('telescope').load_extension('ui-select')
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')

  -- stylua: ignore start
  nmap("<leader>f", builtin.find_files, "Telescope find files")
  nmap("<leader>,", builtin.buffers, "Telescope buffers")
  nmap("<leader>sc", function() builtin.find_files({ cwd = vim.fn.stdpath("config") }) end, "Telescope find neovim configuraition files")
  nmap("<leader>sh", builtin.help_tags, "Telescope help tags")
  nmap("<leader>sg", builtin.live_grep, "Telescope live grep" )
  nmap("<leader>st", builtin.builtin, "Telescope")

-- stylua: ignore end
-- }}}

require('minuet').setup({
  virtualtext = {
    auto_trigger_ft = {},
    keymap = {
      -- accept whole completion
      accept = '<A-A>',
      -- accept one line
      accept_line = '<A-a>',
      -- accept n lines (prompts for number)
      -- e.g. "A-z 2 CR" will accept 2 lines
      accept_n_lines = '<A-z>',
      -- Cycle to prev completion item, or manually invoke completion
      prev = '<A-[>',
      -- Cycle to next completion item, or manually invoke completion
      next = '<A-]>',
      dismiss = '<A-e>',
    },
  },
  provider = 'openai_fim_compatible',
  provider_options = {
    openai_fim_compatible = {
      api_key = vim.env.DEEPSEEK_API_KEY,
      name = 'deepseek',
      optional = {
        max_tokens = 256,
        top_p = 0.9,
      },
    },
  },
})
-- Codeium {{{
-- require('codeium').setup({
--   enable_cmp_source = false,
--   virtual_text = {
--     enabled = true,
--     key_bindings = {
--       -- Accept the current completion.
--       accept = '<c-f>',
--       -- Accept the next word.
--       accept_word = '<c-l>',
--       -- Accept the next line.
--       -- accept_line = '<c-j>',
--       -- Clear the virtual text.
--       -- clear = '<c-k>',
--       -- Cycle to the next completion.
--       -- next = '<M-]>',
--       -- Cycle to the previous completion.
--       -- prev = '<M-[>',
--     },
--   },
-- })
-- }}}

-- flash
require('flash').setup({
  modes = {
    search = {
      enabled = false,
      highlight = { backdrop = true },
    },
    char = {
      enabled = false,
      highlight = { backdrop = false },
      multi_line = false,
    },
  },
})

-- vimtex
vim.g.vimtex_view_method = 'zathura'

-- Oil
require('oil').setup()

-- Snipets {{{
require('luasnip.loaders.from_vscode').lazy_load()
-- }}}
