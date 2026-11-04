-- Theme switch: keep exactly one colorscheme active.
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    enabled = false,
    opts = {
      flavour = 'latte',
      background = { light = 'latte', dark = 'latte' },
      -- styles = {
      --   comments = {},
      -- },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin-latte')
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    enabled = false,
    priority = 1000,
    opts = {
      style = 'day',
      styles = {
        comments = { italic = false },
      },
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight-day')
    end,
  },
}
