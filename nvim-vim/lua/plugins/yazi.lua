return {
  'mikavilpas/yazi.nvim',
  version = '*',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '-', '<cmd>Yazi<cr>', mode = { 'n', 'v' }, desc = 'Yazi at current file' },
    { '_', '<cmd>Yazi cwd<cr>', desc = 'Yazi in working directory' },
  },
  opts = {
    open_for_directories = false,
    floating_window_scaling_factor = 1,
    yazi_floating_window_border = 'none',
    yazi_floating_window_zindex = 200,
    keymaps = { show_help = '<f1>' },
  },
}
