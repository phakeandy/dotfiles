return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    words = {
      enabled = true,
      debounce = 200,
    },
  },
}
