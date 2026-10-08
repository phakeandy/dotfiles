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
    { '<leader>gst', '<cmd>DiffviewOpen<cr>', desc = 'Diffview: open changes' },
    {
      '<leader>gd',
      '<cmd>DiffviewFileHistory %<cr>',
      desc = 'Diffview: current file history',
    },
    {
      '<leader>gd',
      ":<C-u>'<,'>DiffviewFileHistory<cr>",
      mode = 'x',
      desc = 'Diffview: selected lines history',
    },
    {
      '<leader>glg',
      '<cmd>DiffviewFileHistory<cr>',
      desc = 'Diffview: repository history',
    },
  },
  opts = {
    use_icons = false,
  },
}
