-- Theme switch: keep exactly one colorscheme active.
--
-- The flavour is not written here: ~/bin/theme records it in
-- ~/.config/theme/flavour and lua/config/theme.lua applies it, so tmux, neovim
-- and the shell all follow the same name.
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = {
      -- Only used to keep :set background consistent; config.theme picks the
      -- flavour itself because catppuccin does not watch 'background'.
      background = { light = 'latte', dark = 'mocha' },
      -- styles = {
      --   comments = {},
      -- },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      require('config.theme').apply()
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
