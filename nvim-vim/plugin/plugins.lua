vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/tpope/vim-fugitive',

  -- 'https://github.com/L3MON4D3/LuaSnip',
  -- 'https://github.com/rafamadriz/friendly-snippets',

  -- 'https://github.com/milanglacier/minuet-ai.nvim',
  'https://github.com/stevearc/oil.nvim',

  'https://github.com/sphamba/smear-cursor.nvim',

  'https://github.com/lervag/vimtex',

  -- Improve editer experience plugins
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/keaising/im-select.nvim',
}, { confirm = false })

require('im_select').setup()
require('guess-indent').setup()

require('smear_cursor').setup({
  cursor_color = '#52ad70', -- my terminal cursor color
  time_interval = 7, -- milliseconds
})

-- require('mini.align').setup() -- just use column
require('mini.icons').setup()

-- vimtex
vim.g.vimtex_view_method = 'zathura'
