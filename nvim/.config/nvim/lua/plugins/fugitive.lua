return {
  'tpope/vim-fugitive',
  cmd = { 'Git', 'G' },
  keys = {
    { 'g<space>', ':Git ', desc = 'Git' },
    { '<leader>g', '<cmd>tab Git<cr>', desc = 'Git' },
  },
}
