return {
  'tpope/vim-fugitive',
  cmd = { 'Git', 'G' },
  keys = {
    { 'g<space>', ':Git ', desc = 'Git' },
    { '<leader>g', '<cmd>Git<cr>', desc = 'Git' },
  },
}
