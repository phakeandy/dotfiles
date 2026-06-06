local nmap = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end
local map = vim.keymap.set
local create_autocmd = vim.api.nvim_create_autocmd
local k = vim.keycode

do
  vim.g.mapleader = ' '
  vim.g.maplocalleader = '\\'
  nmap('c', '"_c')
  nmap('-', '<cmd>Oil<cr>')

  local nmap_zz = function(lhs) vim.keymap.set('n', lhs, lhs .. 'zz') end

  vim.cmd([[
    command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
  ]])

  nmap('<leader>d', '<cmd>bd<cr>')
  nmap('<leader>b', ':b')
  -- nmap('<backspace>', [[<c-w><c-w>|<c-w>_]])
  -- nmap('<backspace>', [[<c-w>=]])

  -- map({ 'i', 'c' }, 'jk', '<esc>')
  map('t', '<esc>', '<C-\\><C-n>')

  map('v', '<leader>y', function()
    -- NOTE The standard marks '< and '> do not update until you leave visual mode.
    local region = vim.fn.getregionpos(vim.fn.getpos('v'), vim.fn.getpos('.'), {
      type = 'v',
      exclusive = false,
      eol = false,
    })
    local file_path = vim.fn.expand('%:p')
    local start_line = region[1][1][2]
    local end_line = region[#region][1][2]
    local text = string.format('%s:%d-%d', file_path, start_line, end_line)
    vim.fn.setreg('+', text)
    vim.cmd('normal! \27')
  end)
end

do
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.clipboard = 'unnamedplus'
  vim.g.clipboard = 'win32yank'
  -- vim.o.smartcase = true
  vim.o.ignorecase = true
  vim.o.foldmethod = 'indent'
  vim.o.foldlevel = 99
  vim.o.cursorline = true
  vim.opt.cmdheight = 0
  vim.opt.laststatus = 3 -- Global Statusline
  vim.o.statusline = ''
  vim.o.wrap = true
  vim.o.exrc = true
  vim.o.splitright = true

  vim.o.smarttab = true
  vim.o.smartindent = true

  vim.o.formatoptions = 'tcqjMm' -- Mm 能帮助格式化中文

  vim.o.list = true
  vim.opt.listchars =
    { tab = '» ', trail = '·', nbsp = '␣', precedes = '<', extends = '>' }

  vim.diagnostic.config({
    severity_sort = true,
    -- This filters virtual text and signs to only show Errors
    virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
    signs = false,
    underline = { severity = { min = vim.diagnostic.severity.ERROR } },
  })

  require('vim._core.ui2').enable()
  vim.cmd('packadd! nohlsearch')
  vim.cmd('packadd! matchit')
  vim.cmd('packadd! cfilter')
  -- vim.opt.path:append('**') -- set for :find
  -- vim.o.wildignore = '*/node_modules/*,*/.git/*,*/.svn/*'

  create_autocmd({ 'TextYankPost' }, {
    callback = function() vim.hl.on_yank({ higroup = 'Visual', timeout = 300 }) end,
  })

  -- disable netrw
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_netrw = 1
end

do -- lsp
  local lsp_servers = {
    lua_ls = {
      Lua = { workspace = { library = vim.api.nvim_get_runtime_file('lua', true) } },
    },
    clangd = {},
    rust_analyzer = {},
    gopls = {},
    vtsls = {},
    -- pylsp = {},
    basedpyright = {},
    -- pyright = {},
  }

  vim.pack.add({
    'https://github.com/neovim/nvim-lspconfig', -- default configs for lsps

    'https://github.com/mason-org/mason.nvim', -- package manager
    'https://github.com/mason-org/mason-lspconfig.nvim', -- lspconfig bridge
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim', -- auto installer
  }, { confirm = false })

  require('mason').setup()
  -- require('mason-lspconfig').setup()
  -- require('mason-tool-installer').setup({
  --   ensure_installed = vim.tbl_keys(lsp_servers),
  -- })

  for server, config in pairs(lsp_servers) do
    vim.lsp.config(server, {
      settings = config,

      on_attach = function(_, bufnr)
        -- vim.o.signcolumn = 'yes'
      end,
    })
    vim.lsp.enable(server)
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

  'https://github.com/sphamba/smear-cursor.nvim',

  'https://github.com/lervag/vimtex',

  -- Improve editer experience plugins
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/keaising/im-select.nvim',
  -- 'https://github.com/folke/flash.nvim',
}, { confirm = false })

require('im_select').setup()
require('guess-indent').setup()

require('smear_cursor').setup({
  cursor_color = '#52ad70', -- my terminal cursor color
  time_interval = 7, -- milliseconds
})

do
  vim.o.completeopt = 'menuone,noselect,fuzzy'
  vim.pack.add({
    {
      src = 'https://github.com/Saghen/blink.cmp',
      version = vim.version.range('1.*'),
    },
  })

  require('blink.cmp').setup({
    keymap = {
      -- Manually invoke minuet completion.
      ['<A-y>'] = require('minuet').make_blink_map(),
    },
    sources = {
      default = { 'lsp', 'path', 'buffer', 'snippets' },
      providers = {
        minuet = {
          name = 'minuet',
          module = 'minuet.blink',
          async = true,
          timeout_ms = 3000,
          score_offset = 50, -- Gives minuet higher priority among suggestions
        },
      },
    },
    -- Recommended to avoid unnecessary request
    completion = { trigger = { prefetch_on_insert = false } },
  })
end

-- require('mini.git').setup()
-- require('mini.statusline').setup()
require('mini.align').setup()
require('mini.icons').setup()
-- require('mini.diff').setup()
-- require('mini.files').setup({
--   mappings = {
--     go_in_plus = '<cr>',
--   },
-- })
do
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
end

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

require('minuet').setup({
  virtualtext = {
    auto_trigger_ft = {},
    keymap = {
      -- accept whole completion
      accept = '<c-f>',
      -- accept one line
      -- accept_line = '<A-a>',
      -- accept n lines (prompts for number)
      -- e.g. "A-z 2 CR" will accept 2 lines
      -- accept_n_lines = '<A-z>',
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
      api_key = 'DEEPSEEK_API_KEY',
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
-- require('flash').setup({
--   modes = {
--     search = {
--       enabled = false,
--       highlight = { backdrop = true },
--     },
--     char = {
--       enabled = false,
--       highlight = { backdrop = false },
--       multi_line = false,
--     },
--   },
-- })

-- vimtex
vim.g.vimtex_view_method = 'zathura'

-- Oil
require('oil').setup()

-- Snipets
require('luasnip.loaders.from_vscode').lazy_load()

-- require('jupytext').setup({})
