return {
  'sindrets/diffview.nvim',
  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewFileHistory',
    'DiffviewToggleFiles',
    'DiffviewFocusFiles',
    'DiffviewRefresh',
  },
  keys = {
    { '<leader>gs', '<cmd>DiffviewOpen<cr>', desc = 'Diffview: open changes' },
    -- { '<leader>vc', '<cmd>DiffviewClose<cr>', desc = 'Diffview: close' },
    {
      '<leader>h',
      '<cmd>DiffviewFileHistory %<cr>',
      desc = 'Diffview: current file history',
    },
    {
      '<leader>h',
      ":<C-u>'<,'>DiffviewFileHistory<cr>",
      mode = 'x',
      desc = 'Diffview: selected lines history',
    },
    {
      '<leader>H',
      '<cmd>DiffviewFileHistory<cr>',
      desc = 'Diffview: repository history',
    },
  },
  opts = {
    use_icons = false,
  },
}
