-- Theme switch: keep exactly one colorscheme active.
return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    enabled = false,
    opts = {
      style = 'night',
      styles = {
        comments = { italic = false },
      },
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight-day')
    end,
  },
  -- {
  --   'ellisonleao/gruvbox.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   opts = {
  --     contrast = '',
  --     italic = {
  --       comments = false,
  --     },
  --   },
  --   config = function(_, opts)
  --     vim.o.background = 'dark'
  --     require('gruvbox').setup(opts)
  --     vim.cmd.colorscheme('gruvbox')
  --   end,
  -- },
}
