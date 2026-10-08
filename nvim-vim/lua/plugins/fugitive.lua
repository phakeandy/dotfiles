return {
  'tpope/vim-fugitive',
  cmd = { 'Git', 'G' },
  keys = {
    -- { '<leader>g', '<cmd>Git ++curwin<cr>', desc = 'Git status' },
    { '<leader>ga', '<cmd>Git add %<cr>', desc = 'Git add current file' },
    { '<leader>gcm', '<cmd>Git commit<cr>', desc = 'Git add current file' },
  },
}
