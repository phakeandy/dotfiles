vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/nvim-lualine/lualine.nvim',

  'https://github.com/L3MON4D3/LuaSnip',
  -- 'https://github.com/rafamadriz/friendly-snippets',

  -- 'https://github.com/milanglacier/minuet-ai.nvim',
  'https://github.com/stevearc/oil.nvim',

  'https://github.com/sphamba/smear-cursor.nvim',

  'https://github.com/lervag/vimtex',

  -- Improve editer experience plugins
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/keaising/im-select.nvim',
  -- { src = 'https://github.com/kkew3/jieba.vim', version = 'release' },
  -- 'https://github.com/neo451/jieba.nvim',
}, { confirm = false })

require('im_select').setup()
require('guess-indent').setup()

require('smear_cursor').setup({
  cursor_color = '#52ad70', -- my terminal cursor color
  time_interval = 7, -- milliseconds
})

-- require('mini.align').setup() -- just use column
require('mini.icons').setup()
require('lualine').setup()

require('luasnip.loaders.from_snipmate').lazy_load()

vim.cmd([[
" press <Tab> to expand or jump in a snippet. These can also be mapped separately
" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
" -1 for jumping backwards.
inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>

" For changing choices in choiceNodes (not strictly necessary for a basic setup).
imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
]])

-- vimtex
vim.g.vimtex_view_method = 'zathura'

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind

    -- if name == 'jieba.vim' and (kind == 'update' or kind == 'install') then
    --   vim.cmd('call jieba_vim#install()')
    -- end
  end,
})

vim.g.jieba_vim_keymap = 1
vim.g.jieba_vim_lazy = 1
